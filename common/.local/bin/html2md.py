#!/usr/bin/env uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "beautifulsoup4",
#     "html2text",
#     "httpx",
# ]
# ///


"""
Usage:
  python html2md.py input.html > output.md
"""

import argparse
import hashlib
import logging
import sys
from pathlib import Path
from urllib.parse import urljoin, urlparse

import html2text
import httpx
from bs4 import BeautifulSoup

IMG_DIR_NAME = "img"


def _safe_image_name(url: str) -> str:
    """
    Generate a deterministic, filesystem-safe filename from an image URL.
    """
    parsed = urlparse(url)
    suffix = Path(parsed.path).suffix or ".img"
    digest = hashlib.sha256(url.encode("utf-8")).hexdigest()[:16]
    return f"{digest}{suffix}"


def _download_image(url: str, img_dir: Path, client: httpx.Client, timeout: float = 15.0) -> Path:
    """Download image using the provided `httpx.Client` and return the local Path.

    Dependency injection of `client` makes this function testable and allows
    callers to manage connection pooling.
    """
    img_dir.mkdir(parents=True, exist_ok=True)
    filename = _safe_image_name(url)
    dest = img_dir / filename

    if not dest.exists():
        resp = client.get(url, timeout=timeout)
        resp.raise_for_status()
        dest.write_bytes(resp.content)

    return dest


def html_file_to_markdown(html_path: Path, client: httpx.Client | None = None, timeout: float = 15.0) -> str:
    html = html_path.read_text(encoding="utf-8", errors="replace")
    soup = BeautifulSoup(html, "html.parser")

    # Remove non-content elements
    for tag in soup(["script", "style", "noscript"]):
        tag.decompose()

    base_url = html_path.resolve().as_uri()
    img_dir = html_path.parent / IMG_DIR_NAME

    # Rewrite <img src> to local paths after download. Use the provided
    # `client` if present; otherwise create a short-lived client for the
    # operation. This enables dependency injection for testing.
    should_close = False
    if client is None:
        client = httpx.Client()
        should_close = True

    try:
        for img in soup.find_all("img"):
            src = img.get("src")
            if not src:
                continue

            absolute_url = urljoin(base_url, src)

            try:
                dest_path = _download_image(absolute_url, img_dir, client, timeout=timeout)
                # Use a posix-style relative path for Markdown
                img["src"] = f"{IMG_DIR_NAME}/{dest_path.name}"
            except (httpx.RequestError, httpx.HTTPStatusError, OSError):
                # If download fails, drop the image to avoid broken markdown
                img.decompose()
    finally:
        if should_close:
            client.close()

    converter = html2text.HTML2Text()
    converter.ignore_images = False
    converter.ignore_tables = False
    converter.body_width = 0

    return converter.handle(str(soup))


def main(args: argparse.Namespace) -> int:
    html_path = args.file
    if not html_path.is_file():
        logging.error("Error: file not found: %s", html_path)
        return 1

    # Use a shared client for connection reuse across multiple downloads
    with httpx.Client() as client:
        markdown = html_file_to_markdown(html_path, client=client, timeout=args.timeout)

    sys.stdout.write(markdown)
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="html2md.py",
        description="Convert an HTML file to Markdown and download referenced images.",
    )
    parser.add_argument("file", type=Path, help="Path to input HTML file")
    parser.add_argument(
        "--timeout",
        type=float,
        default=15.0,
        help="HTTP request timeout in seconds (default: 15)",
    )

    # Configure basic logging; callers can override with their own config.
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    parsed_args = parser.parse_args()
    sys.exit(main(parsed_args))
