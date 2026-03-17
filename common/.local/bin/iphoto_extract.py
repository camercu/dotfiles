#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["tabulate>=0.9,<1", "tqdm>=4.66,<5"]
# ///

"""Inspect and export from a legacy iPhoto library package."""

from __future__ import annotations

import argparse
import csv
import hashlib
import re
import shutil
import sqlite3
import sys
from collections import defaultdict
from dataclasses import dataclass, replace
from datetime import UTC, datetime, timedelta
from pathlib import Path
from typing import Any, Callable, Iterable, Sequence

from tabulate import tabulate
from tqdm import tqdm

APPLE_EPOCH = datetime(2001, 1, 1, tzinfo=UTC)
EVENT_ALBUM_TYPE = 7
EVENT_ALBUM_SUBCLASS = 3
DEFAULT_HASH_PREFIX_LENGTH = 12
INVALID_PATH_CHARS = re.compile(r'[<>:"/\\|?*\x00-\x1f]')
WHITESPACE_RE = re.compile(r"\s+")

Handler = Callable[[argparse.Namespace, "IPhotoLibrary"], int]


EVENT_SUMMARY_QUERY = """
    SELECT
        a.modelId AS event_id,
        a.name AS name,
        COUNT(DISTINCT v.masterId) AS photo_count
    FROM RKAlbum AS a
    LEFT JOIN RKAlbumVersion AS av
        ON av.albumId = a.modelId
    LEFT JOIN RKVersion AS v
        ON v.modelId = av.versionId
       AND v.masterId IS NOT NULL
    WHERE a.isInTrash = 0
      AND a.albumType = ?
      AND a.albumSubclass = ?
    GROUP BY a.modelId, a.name
    ORDER BY lower(COALESCE(a.name, '')), a.modelId
"""

EVENT_PHOTOS_QUERY = """
    SELECT DISTINCT
        m.modelId AS master_id,
        COALESCE(m.originalFileName, m.fileName) AS filename,
        m.imagePath AS image_path
    FROM RKAlbum AS a
    JOIN RKAlbumVersion AS av
        ON av.albumId = a.modelId
    JOIN RKVersion AS v
        ON v.modelId = av.versionId
    JOIN RKMaster AS m
        ON m.modelId = v.masterId
    WHERE a.isInTrash = 0
      AND a.albumType = ?
      AND a.albumSubclass = ?
      AND a.modelId = ?
      AND m.isInTrash = 0
      AND m.imagePath IS NOT NULL
    ORDER BY m.imagePath, m.modelId
"""

ALBUM_SUMMARY_QUERY_TEMPLATE = """
    SELECT
        a.modelId AS album_id,
        a.name AS name,
        COUNT(DISTINCT v.masterId) AS photo_count,
        a.albumType AS album_type,
        a.albumSubclass AS album_subclass,
        a.folderUuid AS folder_uuid,
        a.isHidden AS is_hidden,
        a.isMagic AS is_magic
    FROM RKAlbum AS a
    LEFT JOIN RKAlbumVersion AS av
        ON av.albumId = a.modelId
    LEFT JOIN RKVersion AS v
        ON v.modelId = av.versionId
       AND v.masterId IS NOT NULL
    WHERE {where_clause}
    GROUP BY
        a.modelId,
        a.name,
        a.albumType,
        a.albumSubclass,
        a.folderUuid,
        a.isHidden,
        a.isMagic
    ORDER BY
        COUNT(DISTINCT v.masterId) DESC,
        lower(COALESCE(a.name, '')),
        a.modelId
"""

ALBUM_PHOTOS_QUERY = """
    SELECT DISTINCT
        m.modelId AS master_id,
        COALESCE(m.originalFileName, m.fileName) AS filename,
        m.imagePath AS image_path
    FROM RKAlbum AS a
    JOIN RKAlbumVersion AS av
        ON av.albumId = a.modelId
    JOIN RKVersion AS v
        ON v.modelId = av.versionId
    JOIN RKMaster AS m
        ON m.modelId = v.masterId
    WHERE a.isInTrash = 0
      AND a.modelId = ?
      AND m.isInTrash = 0
      AND m.imagePath IS NOT NULL
    ORDER BY m.imagePath, m.modelId
"""

FOLDER_SUMMARY_QUERY_TEMPLATE = """
    SELECT
        f.modelId AS folder_id,
        f.uuid AS uuid,
        f.name AS name,
        f.folderType AS folder_type,
        f.parentFolderUuid AS parent_folder_uuid,
        COUNT(DISTINCT a.modelId) AS album_count,
        COUNT(DISTINCT m.modelId) AS photo_count,
        f.isHidden AS is_hidden,
        f.isMagic AS is_magic
    FROM RKFolder AS f
    LEFT JOIN RKAlbum AS a
        ON a.folderUuid = f.uuid
       AND a.isInTrash = 0
    LEFT JOIN RKMaster AS m
        ON m.projectUuid = f.uuid
       AND m.isInTrash = 0
       AND m.imagePath IS NOT NULL
    WHERE {where_clause}
    GROUP BY
        f.modelId,
        f.uuid,
        f.name,
        f.folderType,
        f.parentFolderUuid,
        f.isHidden,
        f.isMagic
    ORDER BY
        COUNT(DISTINCT m.modelId) DESC,
        COUNT(DISTINCT a.modelId) DESC,
        lower(COALESCE(f.name, '')),
        f.modelId
"""

FOLDER_PHOTOS_QUERY = """
    SELECT
        m.modelId AS master_id,
        COALESCE(m.originalFileName, m.fileName) AS filename,
        m.imagePath AS image_path
    FROM RKMaster AS m
    WHERE m.isInTrash = 0
      AND m.projectUuid = ?
      AND m.imagePath IS NOT NULL
    ORDER BY m.imagePath, m.modelId
"""

MASTER_ASSETS_QUERY = """
    SELECT
        modelId,
        COALESCE(originalFileName, fileName) AS filename,
        imagePath,
        projectUuid,
        imageDate,
        fileCreationDate,
        fileModificationDate
    FROM RKMaster
    WHERE isInTrash = 0
      AND imagePath IS NOT NULL
    ORDER BY imagePath, modelId
"""

MASTER_EVENT_NAME_QUERY = """
    SELECT
        v.masterId AS master_id,
        a.name AS event_name
    FROM RKAlbum AS a
    JOIN RKAlbumVersion AS av
        ON av.albumId = a.modelId
    JOIN RKVersion AS v
        ON v.modelId = av.versionId
    WHERE a.isInTrash = 0
      AND a.albumType = ?
      AND a.albumSubclass = ?
      AND v.masterId IS NOT NULL
    ORDER BY lower(COALESCE(a.name, '')), a.modelId, v.masterId
"""


class IPhotoError(Exception):
    """Raised when the iPhoto library cannot be read as expected."""


@dataclass(frozen=True)
class EventSummary:
    event_id: int
    name: str
    photo_count: int


@dataclass(frozen=True)
class AlbumSummary:
    album_id: int
    name: str
    photo_count: int
    album_type: int
    album_subclass: int
    folder_uuid: str | None
    is_hidden: bool
    is_magic: bool


@dataclass(frozen=True)
class FolderSummary:
    folder_id: int
    uuid: str
    name: str
    folder_type: int
    parent_folder_uuid: str | None
    album_count: int
    photo_count: int
    is_hidden: bool
    is_magic: bool


@dataclass(frozen=True)
class ImportGroupSummary:
    group_path: str
    photo_count: int
    project_count: int


@dataclass(frozen=True)
class AssetPath:
    master_id: int
    filename: str
    image_path: str

    def full_path(self, library_root: Path) -> Path:
        return library_root / "Masters" / Path(self.image_path)


@dataclass(frozen=True)
class MasterAsset:
    master_id: int
    filename: str
    image_path: str
    source_path: Path
    project_uuid: str | None
    capture_date: datetime | None
    content_hash: str | None = None

    @property
    def import_group(self) -> str:
        return Path(self.image_path).parent.as_posix()


@dataclass(frozen=True)
class PlannedExport:
    source_path: Path
    destination_path: Path
    mode: str
    bucket: str


class IPhotoLibrary:
    """Repository for iPhoto metadata and asset discovery."""

    def __init__(self, library_root: Path) -> None:
        self.library_root = self._validate_library_root(library_root)
        self.database_path = self.library_root / "Database" / "apdb" / "Library.apdb"

    @staticmethod
    def _validate_library_root(library_root: Path) -> Path:
        resolved = library_root.expanduser().resolve()
        if not resolved.exists():
            raise IPhotoError(f"Library does not exist: {resolved}")
        if not resolved.is_dir():
            raise IPhotoError(f"Library must be a directory: {resolved}")
        if resolved.suffix != ".photolibrary":
            raise IPhotoError(
                f"Expected an unzipped .photolibrary package, got: {resolved.name}"
            )

        db_path = resolved / "Database" / "apdb" / "Library.apdb"
        masters_path = resolved / "Masters"
        if not db_path.is_file():
            raise IPhotoError(f"Missing iPhoto database: {db_path}")
        if not masters_path.is_dir():
            raise IPhotoError(f"Missing Masters folder: {masters_path}")
        return resolved

    def _connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(f"file:{self.database_path}?mode=ro", uri=True)
        connection.row_factory = sqlite3.Row
        return connection

    def _fetch_rows(self, query: str, params: Sequence[Any] = ()) -> list[sqlite3.Row]:
        with self._connect() as connection:
            return connection.execute(query, tuple(params)).fetchall()

    @staticmethod
    def _row_name(value: object) -> str:
        return str(value or "").strip()

    @staticmethod
    def _apple_timestamp_to_datetime(value: object) -> datetime | None:
        if value is None:
            return None
        try:
            return APPLE_EPOCH + timedelta(seconds=float(value))
        except (TypeError, ValueError, OverflowError):
            return None

    @staticmethod
    def _summary_name(name: str, fallback: str) -> str:
        return name or fallback

    def _make_event_summary(self, row: sqlite3.Row) -> EventSummary:
        return EventSummary(
            event_id=int(row["event_id"]),
            name=self._summary_name(self._row_name(row["name"]), "(untitled event)"),
            photo_count=int(row["photo_count"]),
        )

    def _make_album_summary(self, row: sqlite3.Row) -> AlbumSummary:
        return AlbumSummary(
            album_id=int(row["album_id"]),
            name=self._summary_name(self._row_name(row["name"]), "(untitled album)"),
            photo_count=int(row["photo_count"]),
            album_type=int(row["album_type"]),
            album_subclass=int(row["album_subclass"]),
            folder_uuid=str(row["folder_uuid"]) if row["folder_uuid"] else None,
            is_hidden=bool(row["is_hidden"]),
            is_magic=bool(row["is_magic"]),
        )

    def _make_folder_summary(self, row: sqlite3.Row) -> FolderSummary:
        return FolderSummary(
            folder_id=int(row["folder_id"]),
            uuid=str(row["uuid"]),
            name=self._summary_name(self._row_name(row["name"]), "(untitled folder)"),
            folder_type=int(row["folder_type"]),
            parent_folder_uuid=(
                str(row["parent_folder_uuid"]) if row["parent_folder_uuid"] else None
            ),
            album_count=int(row["album_count"]),
            photo_count=int(row["photo_count"]),
            is_hidden=bool(row["is_hidden"]),
            is_magic=bool(row["is_magic"]),
        )

    def _make_asset_path(self, row: sqlite3.Row) -> AssetPath:
        return AssetPath(
            master_id=int(row["master_id"]),
            filename=self._row_name(row["filename"]),
            image_path=str(row["image_path"]),
        )

    def _filtered_album_rows(
        self,
        *,
        include_hidden: bool,
        include_magic: bool,
    ) -> list[sqlite3.Row]:
        clauses = ["a.isInTrash = 0"]
        if not include_hidden:
            clauses.append("a.isHidden = 0")
        if not include_magic:
            clauses.append("a.isMagic = 0")
        return self._fetch_rows(
            ALBUM_SUMMARY_QUERY_TEMPLATE.format(where_clause=" AND ".join(clauses))
        )

    def _filtered_folder_rows(
        self,
        *,
        include_hidden: bool,
        include_magic: bool,
    ) -> list[sqlite3.Row]:
        clauses = ["f.isInTrash = 0"]
        if not include_hidden:
            clauses.append("f.isHidden = 0")
        if not include_magic:
            clauses.append("f.isMagic = 0")
        return self._fetch_rows(
            FOLDER_SUMMARY_QUERY_TEMPLATE.format(where_clause=" AND ".join(clauses))
        )

    def list_events(self) -> list[EventSummary]:
        return [
            self._make_event_summary(row)
            for row in self._fetch_rows(
                EVENT_SUMMARY_QUERY, (EVENT_ALBUM_TYPE, EVENT_ALBUM_SUBCLASS)
            )
        ]

    def get_event_by_id(self, event_id: int) -> EventSummary | None:
        return next(
            (item for item in self.list_events() if item.event_id == event_id), None
        )

    def get_events_by_name(self, name: str) -> list[EventSummary]:
        lowered = name.casefold()
        return [item for item in self.list_events() if item.name.casefold() == lowered]

    def list_event_photos(self, event_id: int) -> list[AssetPath]:
        return [
            self._make_asset_path(row)
            for row in self._fetch_rows(
                EVENT_PHOTOS_QUERY,
                (EVENT_ALBUM_TYPE, EVENT_ALBUM_SUBCLASS, event_id),
            )
        ]

    def list_albums(
        self,
        *,
        include_empty: bool = False,
        include_hidden: bool = False,
        include_magic: bool = False,
    ) -> list[AlbumSummary]:
        items = [
            self._make_album_summary(row)
            for row in self._filtered_album_rows(
                include_hidden=include_hidden,
                include_magic=include_magic,
            )
        ]
        return (
            items if include_empty else [item for item in items if item.photo_count > 0]
        )

    def get_album_by_id(self, album_id: int) -> AlbumSummary | None:
        return next(
            (
                item
                for item in self.list_albums(
                    include_empty=True,
                    include_hidden=True,
                    include_magic=True,
                )
                if item.album_id == album_id
            ),
            None,
        )

    def get_albums_by_name(self, name: str) -> list[AlbumSummary]:
        lowered = name.casefold()
        return [
            item
            for item in self.list_albums(
                include_empty=True,
                include_hidden=True,
                include_magic=True,
            )
            if item.name.casefold() == lowered
        ]

    def list_album_photos(self, album_id: int) -> list[AssetPath]:
        return [
            self._make_asset_path(row)
            for row in self._fetch_rows(ALBUM_PHOTOS_QUERY, (album_id,))
        ]

    def list_folders(
        self,
        *,
        include_empty: bool = False,
        include_hidden: bool = False,
        include_magic: bool = False,
    ) -> list[FolderSummary]:
        items = [
            self._make_folder_summary(row)
            for row in self._filtered_folder_rows(
                include_hidden=include_hidden,
                include_magic=include_magic,
            )
        ]
        return (
            items
            if include_empty
            else [
                item for item in items if item.photo_count > 0 or item.album_count > 0
            ]
        )

    def get_folder_by_id(self, folder_id: int) -> FolderSummary | None:
        return next(
            (
                item
                for item in self.list_folders(
                    include_empty=True,
                    include_hidden=True,
                    include_magic=True,
                )
                if item.folder_id == folder_id
            ),
            None,
        )

    def get_folder_by_uuid(self, folder_uuid: str) -> FolderSummary | None:
        return next(
            (
                item
                for item in self.list_folders(
                    include_empty=True,
                    include_hidden=True,
                    include_magic=True,
                )
                if item.uuid == folder_uuid
            ),
            None,
        )

    def get_folders_by_name(self, name: str) -> list[FolderSummary]:
        lowered = name.casefold()
        return [
            item
            for item in self.list_folders(
                include_empty=True,
                include_hidden=True,
                include_magic=True,
            )
            if item.name.casefold() == lowered
        ]

    def list_folder_photos(self, folder_uuid: str) -> list[AssetPath]:
        return [
            self._make_asset_path(row)
            for row in self._fetch_rows(FOLDER_PHOTOS_QUERY, (folder_uuid,))
        ]

    def list_master_assets(self) -> list[MasterAsset]:
        assets: list[MasterAsset] = []
        for row in self._fetch_rows(MASTER_ASSETS_QUERY):
            capture_date = (
                self._apple_timestamp_to_datetime(row["imageDate"])
                or self._apple_timestamp_to_datetime(row["fileCreationDate"])
                or self._apple_timestamp_to_datetime(row["fileModificationDate"])
            )
            image_path = str(row["imagePath"])
            assets.append(
                MasterAsset(
                    master_id=int(row["modelId"]),
                    filename=self._row_name(row["filename"]) or Path(image_path).name,
                    image_path=image_path,
                    source_path=self.library_root / "Masters" / Path(image_path),
                    project_uuid=str(row["projectUuid"])
                    if row["projectUuid"]
                    else None,
                    capture_date=capture_date,
                )
            )
        return assets

    def list_import_groups(self) -> list[ImportGroupSummary]:
        counts: dict[str, int] = defaultdict(int)
        project_counts: dict[str, set[str]] = defaultdict(set)
        for asset in self.list_master_assets():
            counts[asset.import_group] += 1
            if asset.project_uuid:
                project_counts[asset.import_group].add(asset.project_uuid)
        return sorted(
            [
                ImportGroupSummary(
                    group_path=group_path,
                    photo_count=counts[group_path],
                    project_count=len(project_counts[group_path]),
                )
                for group_path in counts
            ],
            key=lambda item: (-item.photo_count, item.group_path),
        )

    def list_import_group_photos(self, group_path: str) -> list[AssetPath]:
        normalized_group = normalize_relative_group(group_path)
        items = [
            AssetPath(
                master_id=asset.master_id,
                filename=asset.filename,
                image_path=asset.image_path,
            )
            for asset in self.list_master_assets()
            if asset.import_group == normalized_group
        ]
        if not items:
            raise IPhotoError(f'No import group found with path "{normalized_group}".')
        return items

    def master_event_name_map(self) -> dict[int, str]:
        event_names: dict[int, str] = {}
        for row in self._fetch_rows(
            MASTER_EVENT_NAME_QUERY, (EVENT_ALBUM_TYPE, EVENT_ALBUM_SUBCLASS)
        ):
            master_id = int(row["master_id"])
            event_names.setdefault(
                master_id,
                self._summary_name(
                    self._row_name(row["event_name"]), "(untitled event)"
                ),
            )
        return event_names

    def folder_uuid_name_map(self) -> dict[str, str]:
        return {
            folder.uuid: folder.name
            for folder in self.list_folders(
                include_empty=True,
                include_hidden=True,
                include_magic=True,
            )
        }


def normalize_label(value: str, fallback: str) -> str:
    cleaned = INVALID_PATH_CHARS.sub("_", value)
    cleaned = WHITESPACE_RE.sub(" ", cleaned).strip().strip(".")
    return cleaned or fallback


def normalize_relative_group(group_path: str) -> str:
    parts = [
        normalize_label(part, "untitled") for part in Path(group_path).parts if part
    ]
    return Path(*parts).as_posix()


def year_month_bucket(asset: MasterAsset) -> str:
    return (
        "unknown-date"
        if asset.capture_date is None
        else f"{asset.capture_date:%Y}/{asset.capture_date:%m}"
    )


def export_bucket_for_asset(
    *,
    asset: MasterAsset,
    mode: str,
    event_names: dict[int, str],
    folder_names: dict[str, str],
) -> str:
    if mode == "event":
        event_name = event_names.get(asset.master_id)
        return (
            normalize_relative_group(event_name)
            if event_name
            else year_month_bucket(asset)
        )
    if mode == "folder":
        folder_name = folder_names.get(asset.project_uuid or "")
        return (
            normalize_relative_group(folder_name)
            if folder_name
            else year_month_bucket(asset)
        )
    if mode == "import-group":
        return normalize_relative_group(asset.import_group)
    raise IPhotoError(f"Unsupported plan-export mode: {mode}")


def dated_hash_filename(
    asset: MasterAsset,
    *,
    hash_prefix_length: int = DEFAULT_HASH_PREFIX_LENGTH,
) -> str:
    if asset.content_hash is None:
        raise IPhotoError("Content hash missing for export naming.")
    date_part = (
        asset.capture_date.strftime("%Y-%m-%d")
        if asset.capture_date
        else "unknown-date"
    )
    extension = Path(asset.filename).suffix.lower() or asset.source_path.suffix.lower()
    return f"{date_part}-{asset.content_hash[:hash_prefix_length]}{extension}"


def planned_destination_path(
    *,
    directory: Path,
    asset: MasterAsset,
    seen_destinations: set[str],
) -> Path:
    candidate = directory / dated_hash_filename(asset)
    key = candidate.as_posix().casefold()
    if key not in seen_destinations:
        seen_destinations.add(key)
        return candidate

    extension = candidate.suffix
    stem = candidate.stem
    collision_safe = directory / f"{stem}-m{asset.master_id}{extension}"
    collision_key = collision_safe.as_posix().casefold()
    if collision_key in seen_destinations:
        raise IPhotoError(
            f"Destination collision remained even after master id fallback: {collision_safe}"
        )
    seen_destinations.add(collision_key)
    return collision_safe


def build_export_plans(
    *,
    assets: Sequence[MasterAsset],
    mode: str,
    event_names: dict[int, str],
    folder_names: dict[str, str],
    dest_root: Path | None = None,
) -> list[PlannedExport]:
    seen_destinations: set[str] = set()
    plans: list[PlannedExport] = []
    for asset in assets:
        bucket = export_bucket_for_asset(
            asset=asset,
            mode=mode,
            event_names=event_names,
            folder_names=folder_names,
        )
        relative_destination = planned_destination_path(
            directory=Path(bucket),
            asset=asset,
            seen_destinations=seen_destinations,
        )
        destination_path = (
            dest_root / relative_destination if dest_root else relative_destination
        )
        plans.append(
            PlannedExport(
                source_path=asset.source_path,
                destination_path=destination_path,
                mode=mode,
                bucket=bucket,
            )
        )
    return plans


def summarize_plans(plans: Sequence[PlannedExport]) -> list[tuple[str, int]]:
    bucket_counts: dict[str, int] = defaultdict(int)
    for plan in plans:
        bucket_counts[plan.bucket] += 1
    return sorted(bucket_counts.items(), key=lambda item: (-item[1], item[0]))


def hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        while chunk := handle.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def attach_content_hashes(
    assets: Sequence[MasterAsset],
    *,
    show_progress: bool,
) -> list[MasterAsset]:
    iterator: Iterable[MasterAsset]
    progress: tqdm[MasterAsset] | None = None
    if show_progress:
        progress = tqdm(assets, desc="Hashing assets", unit="file")
        iterator = progress
    else:
        iterator = assets

    hashed_assets: list[MasterAsset] = []
    try:
        for asset in iterator:
            if progress is not None:
                progress.set_postfix_str(asset.source_path.name, refresh=False)
            hashed_assets.append(
                replace(asset, content_hash=hash_file(asset.source_path))
            )
    finally:
        if progress is not None:
            progress.close()
    return hashed_assets


def plan_exports_from_library(
    library: IPhotoLibrary,
    *,
    mode: str,
    dest_root: Path | None = None,
    show_progress: bool,
) -> list[PlannedExport]:
    assets = attach_content_hashes(
        library.list_master_assets(),
        show_progress=show_progress,
    )
    event_names = library.master_event_name_map() if mode == "event" else {}
    folder_names = library.folder_uuid_name_map() if mode == "folder" else {}
    return build_export_plans(
        assets=assets,
        mode=mode,
        event_names=event_names,
        folder_names=folder_names,
        dest_root=dest_root,
    )


def render_table(headers: list[str], rows: Iterable[Iterable[object]]) -> str:
    return tabulate(list(rows), headers=headers, tablefmt="github")


def render_plan_table(plans: Sequence[PlannedExport]) -> str:
    return render_table(
        ["mode", "bucket", "source", "destination"],
        (
            (
                plan.mode,
                plan.bucket,
                str(plan.source_path),
                str(plan.destination_path),
            )
            for plan in plans
        ),
    )


def render_plan_summary_table(
    plans: Sequence[PlannedExport],
    *,
    limit: int | None = None,
) -> str:
    rows = summarize_plans(plans)
    if limit is not None:
        rows = rows[:limit]
    return render_table(["bucket", "file_count"], rows)


def write_manifest(manifest_path: Path, plans: Sequence[PlannedExport]) -> None:
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with manifest_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["mode", "bucket", "source", "destination"])
        for plan in plans:
            writer.writerow(
                [
                    plan.mode,
                    plan.bucket,
                    str(plan.source_path),
                    str(plan.destination_path),
                ]
            )


def execute_export(
    plans: Sequence[PlannedExport],
    *,
    show_progress: bool,
) -> None:
    iterator: Iterable[PlannedExport]
    progress: tqdm[PlannedExport] | None = None
    if show_progress:
        progress = tqdm(plans, desc="Copying assets", unit="file")
        iterator = progress
    else:
        iterator = plans

    try:
        for plan in iterator:
            if progress is not None:
                progress.set_postfix_str(plan.destination_path.name, refresh=False)
            plan.destination_path.parent.mkdir(parents=True, exist_ok=True)
            if plan.destination_path.exists():
                raise IPhotoError(
                    f"Destination already exists: {plan.destination_path}"
                )
            shutil.copy2(plan.source_path, plan.destination_path)
    finally:
        if progress is not None:
            progress.close()


def resolve_event(args: argparse.Namespace, library: IPhotoLibrary) -> EventSummary:
    if args.event_id is not None:
        event = library.get_event_by_id(args.event_id)
        if event is None:
            raise IPhotoError(f"No event found with id {args.event_id}.")
        return event

    matches = library.get_events_by_name(args.event)
    if not matches:
        raise IPhotoError(f'No event found with name "{args.event}".')
    if len(matches) > 1:
        options = ", ".join(str(match.event_id) for match in matches)
        raise IPhotoError(
            f'Multiple events matched "{args.event}". Use --event-id one of: {options}'
        )
    return matches[0]


def resolve_album(args: argparse.Namespace, library: IPhotoLibrary) -> AlbumSummary:
    if args.album_id is not None:
        album = library.get_album_by_id(args.album_id)
        if album is None:
            raise IPhotoError(f"No album found with id {args.album_id}.")
        return album

    matches = library.get_albums_by_name(args.album)
    if not matches:
        raise IPhotoError(f'No album found with name "{args.album}".')
    if len(matches) > 1:
        options = ", ".join(str(match.album_id) for match in matches)
        raise IPhotoError(
            f'Multiple albums matched "{args.album}". Use --album-id one of: {options}'
        )
    return matches[0]


def resolve_folder(args: argparse.Namespace, library: IPhotoLibrary) -> FolderSummary:
    if args.folder_id is not None:
        folder = library.get_folder_by_id(args.folder_id)
        if folder is None:
            raise IPhotoError(f"No folder found with id {args.folder_id}.")
        return folder

    if args.folder_uuid is not None:
        folder = library.get_folder_by_uuid(args.folder_uuid)
        if folder is None:
            raise IPhotoError(f'No folder found with UUID "{args.folder_uuid}".')
        return folder

    matches = library.get_folders_by_name(args.folder)
    if not matches:
        raise IPhotoError(f'No folder found with name "{args.folder}".')
    if len(matches) > 1:
        options = ", ".join(str(match.folder_id) for match in matches)
        raise IPhotoError(
            f'Multiple folders matched "{args.folder}". Use --folder-id one of: {options}'
        )
    return matches[0]


def validate_paths_args(args: argparse.Namespace) -> None:
    if args.kind == "event" and args.event is None and args.event_id is None:
        raise IPhotoError("`paths event` requires --event or --event-id.")
    if args.kind == "album" and args.album is None and args.album_id is None:
        raise IPhotoError("`paths album` requires --album or --album-id.")
    if (
        args.kind == "folder"
        and args.folder is None
        and args.folder_id is None
        and args.folder_uuid is None
    ):
        raise IPhotoError(
            "`paths folder` requires --folder, --folder-id, or --folder-uuid."
        )
    if args.kind == "import-group" and not args.group:
        raise IPhotoError("`paths import-group` requires --group.")


def print_asset_paths(paths: Iterable[AssetPath], library: IPhotoLibrary) -> int:
    for asset in paths:
        print(asset.full_path(library.library_root))
    return 0


def cmd_list(args: argparse.Namespace, library: IPhotoLibrary) -> int:
    if args.kind == "events":
        rows = (
            (event.event_id, event.photo_count, event.name)
            for event in library.list_events()
        )
        print(render_table(["event_id", "photo_count", "name"], rows))
        return 0

    if args.kind == "albums":
        items = library.list_albums(
            include_empty=args.include_empty,
            include_hidden=args.include_hidden,
            include_magic=args.include_magic,
        )
        rows = (
            (
                item.album_id,
                item.photo_count,
                item.album_type,
                item.album_subclass,
                item.name,
            )
            for item in items
        )
        print(
            render_table(
                ["album_id", "photo_count", "album_type", "album_subclass", "name"],
                rows,
            )
        )
        return 0

    if args.kind == "folders":
        items = library.list_folders(
            include_empty=args.include_empty,
            include_hidden=args.include_hidden,
            include_magic=args.include_magic,
        )
        rows = (
            (
                item.folder_id,
                item.photo_count,
                item.album_count,
                item.folder_type,
                item.uuid,
                item.name,
            )
            for item in items
        )
        print(
            render_table(
                [
                    "folder_id",
                    "photo_count",
                    "album_count",
                    "folder_type",
                    "uuid",
                    "name",
                ],
                rows,
            )
        )
        return 0

    if args.kind == "import-groups":
        rows = (
            (item.photo_count, item.project_count, item.group_path)
            for item in library.list_import_groups()
        )
        print(render_table(["photo_count", "project_count", "group_path"], rows))
        return 0

    raise IPhotoError(f"Unsupported list kind: {args.kind}")


def cmd_paths(args: argparse.Namespace, library: IPhotoLibrary) -> int:
    validate_paths_args(args)

    if args.kind == "event":
        return print_asset_paths(
            library.list_event_photos(resolve_event(args, library).event_id),
            library,
        )

    if args.kind == "album":
        return print_asset_paths(
            library.list_album_photos(resolve_album(args, library).album_id),
            library,
        )

    if args.kind == "folder":
        return print_asset_paths(
            library.list_folder_photos(resolve_folder(args, library).uuid),
            library,
        )

    if args.kind == "import-group":
        return print_asset_paths(library.list_import_group_photos(args.group), library)

    raise IPhotoError(f"Unsupported paths kind: {args.kind}")


def cmd_plan(args: argparse.Namespace, library: IPhotoLibrary) -> int:
    dest_root = args.dest_root.expanduser().resolve() if args.dest_root else None
    plans = plan_exports_from_library(
        library,
        mode=args.mode,
        dest_root=dest_root,
        show_progress=True,
    )
    if args.summary:
        print(f"total_files: {len(plans)}")
        print(
            f"unique_destinations: {len({str(plan.destination_path) for plan in plans})}"
        )
        print(f"bucket_count: {len({plan.bucket for plan in plans})}")
        print()
        print(render_plan_summary_table(plans, limit=args.limit))
        return 0

    if args.limit is not None:
        plans = plans[: args.limit]
    print(render_plan_table(plans))
    return 0


def cmd_export(args: argparse.Namespace, library: IPhotoLibrary) -> int:
    dest_root = args.dest_root.expanduser().resolve()
    plans = plan_exports_from_library(
        library,
        mode=args.mode,
        dest_root=dest_root,
        show_progress=True,
    )

    manifest_path: Path | None = None
    if args.manifest is not None:
        manifest_path = args.manifest.expanduser().resolve()
        write_manifest(manifest_path, plans)

    if args.execute:
        execute_export(plans, show_progress=True)
        print(f"Copied {len(plans)} files to {dest_root}")
        if manifest_path is not None:
            print(f"Manifest: {manifest_path}")
        return 0

    display_plans = plans[: args.limit] if args.limit is not None else plans
    print(render_plan_table(display_plans))
    if manifest_path is not None:
        print(f"\nManifest: {manifest_path}")
    return 0


def add_library_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--library",
        required=True,
        type=Path,
        help="Path to an unzipped iPhoto .photolibrary package.",
    )


def add_mode_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--mode",
        choices=("event", "folder", "import-group"),
        default="event",
        help="Grouping strategy for destination folders.",
    )


def register_list_command(
    subparsers: argparse._SubParsersAction[argparse.ArgumentParser],
) -> None:
    parser = subparsers.add_parser(
        "list", help="List events, albums, folders, or import groups."
    )
    parser.add_argument(
        "kind",
        choices=("events", "albums", "folders", "import-groups"),
        help="What kind of metadata to list.",
    )
    parser.add_argument(
        "--include-empty",
        action="store_true",
        help="Include zero-count albums or folders.",
    )
    parser.add_argument(
        "--include-hidden",
        action="store_true",
        help="Include hidden albums or folders.",
    )
    parser.add_argument(
        "--include-magic",
        action="store_true",
        help="Include magic/system albums or folders.",
    )
    parser.set_defaults(handler=cmd_list)


def register_paths_command(
    subparsers: argparse._SubParsersAction[argparse.ArgumentParser],
) -> None:
    parser = subparsers.add_parser(
        "paths", help="List full master file paths for one target group."
    )
    parser.add_argument(
        "kind",
        choices=("event", "album", "folder", "import-group"),
        help="What kind of target to resolve.",
    )
    selector = parser.add_mutually_exclusive_group()
    selector.add_argument("--event", help="Event name (case-insensitive exact match).")
    selector.add_argument("--event-id", type=int, help="Event id from `list events`.")
    selector.add_argument("--album", help="Album name (case-insensitive exact match).")
    selector.add_argument("--album-id", type=int, help="Album id from `list albums`.")
    selector.add_argument(
        "--folder", help="Folder name (case-insensitive exact match)."
    )
    selector.add_argument(
        "--folder-id", type=int, help="Folder id from `list folders`."
    )
    selector.add_argument("--folder-uuid", help="Folder UUID from `list folders`.")
    parser.add_argument(
        "--group", help="Relative import-group path like 2016/06/11/20160611-162306."
    )
    parser.set_defaults(handler=cmd_paths)


def register_plan_command(
    subparsers: argparse._SubParsersAction[argparse.ArgumentParser],
) -> None:
    parser = subparsers.add_parser(
        "plan", help="Plan exports or summarize planned destination buckets."
    )
    add_mode_argument(parser)
    parser.add_argument(
        "--dest-root",
        type=Path,
        help="Optional destination root to prefix onto planned relative paths.",
    )
    parser.add_argument(
        "--summary",
        action="store_true",
        help="Show a per-bucket summary instead of per-file mappings.",
    )
    parser.add_argument("--limit", type=int, help="Limit printed rows or buckets.")
    parser.set_defaults(handler=cmd_plan)


def register_export_command(
    subparsers: argparse._SubParsersAction[argparse.ArgumentParser],
) -> None:
    parser = subparsers.add_parser(
        "export", help="Dry-run or execute an export using the planner."
    )
    add_mode_argument(parser)
    parser.add_argument(
        "--dest-root",
        required=True,
        type=Path,
        help="Destination root for copied files.",
    )
    export_mode = parser.add_mutually_exclusive_group()
    export_mode.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the planned exports without copying files.",
    )
    export_mode.add_argument(
        "--execute", action="store_true", help="Copy files to the destination root."
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        help="Optional CSV manifest path for the planned exports.",
    )
    parser.add_argument(
        "--limit", type=int, help="Only print the first N planned rows during dry runs."
    )
    parser.set_defaults(handler=cmd_export)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Inspect an unzipped iPhoto .photolibrary package."
    )
    add_library_argument(parser)
    subparsers = parser.add_subparsers(dest="command", required=True)

    register_list_command(subparsers)
    register_paths_command(subparsers)
    register_plan_command(subparsers)
    register_export_command(subparsers)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    handler: Handler | None = getattr(args, "handler", None)
    if handler is None:
        parser.error(f"Unsupported command: {args.command}")

    try:
        library = IPhotoLibrary(args.library)
        return handler(args, library)
    except IPhotoError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
