#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)

resolve_path() {
  python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

run_dotsync_smoke_test() {
  # Resolve to the physical path: on macOS $TMPDIR lives under /var -> /private/var,
  # and stow resolves that symlink when computing relative links. Fabricating the
  # pre-existing link from the unresolved path yields a target stow would never
  # create, so stow rejects it as "not owned by stow". Resolving keeps the
  # simulated link identical to a real stow-owned one.
  tmp_home=$(CDPATH= cd -- "$(mktemp -d "${TMPDIR:-/tmp}/dotsync-home.XXXXXX")" && pwd -P)
  rel_target=$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' \
    "$DOTFILE_DIR/common/.bash_aliases" "$tmp_home")

  ln -s "$rel_target" "$tmp_home/.bash_aliases"

  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >/dev/null 2>&1
  [ -L "$tmp_home/.bash_aliases" ]
  [ "$(resolve_path "$tmp_home/.bash_aliases")" = "$(resolve_path "$DOTFILE_DIR/common/.bash_aliases")" ]

  HOME="$tmp_home" "$SCRIPT_DIR/uninstall-dotfiles.sh" >/dev/null 2>&1
  [ ! -L "$tmp_home/.bash_aliases" ]

  ln -s "$rel_target" "$tmp_home/.bash_aliases"
  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" --auto-discover >/dev/null 2>&1
  [ -L "$tmp_home/.bash_aliases" ]
  [ "$(resolve_path "$tmp_home/.bash_aliases")" = "$(resolve_path "$DOTFILE_DIR/common/.bash_aliases")" ]

  rm -rf "$tmp_home"
}

run_repo_relative_link_test() {
  tmp_home=$(mktemp -d "$DOTFILE_DIR/.tmp-dotsync-home.XXXXXX")
  rel_target=$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' \
    "$DOTFILE_DIR/common/.bash_aliases" "$tmp_home")

  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >/dev/null 2>&1
  [ -L "$tmp_home/.bash_aliases" ]
  [ "$(resolve_path "$tmp_home/.bash_aliases")" = "$(resolve_path "$DOTFILE_DIR/common/.bash_aliases")" ]

  HOME="$tmp_home" "$SCRIPT_DIR/uninstall-dotfiles.sh" >/dev/null 2>&1
  rm -rf "$tmp_home"
}

# `sh -n`/`zsh -n` never resolve `source` targets, so a script pointing at a
# deleted lib still passes syntax checks and only breaks at runtime (silently,
# when nothing sets -e). Assert every lib/<file> referenced by a script exists.
run_sourced_lib_test() {
  lib_status=0
  for script in "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/*.zsh "$DOTFILE_DIR/common/.local/bin/dotsync"; do
    [ -f "$script" ] || continue
    for lib in $(grep -ohE '(source|\.) "[^"]*lib[^"]*"' "$script" \
        | sed -E 's|.*/([^/"]+)".*|\1|' | sort -u); do
      if [ ! -f "$SCRIPT_DIR/lib/$lib" ]; then
        echo "$script references missing scripts/lib/$lib" >&2
        lib_status=1
      fi
    done
  done
  return "$lib_status"
}

run_stow_conflict_test() {
  tmp_home=$(mktemp -d "${TMPDIR:-/tmp}/dotsync-conflict.XXXXXX")
  conflict_log=$(mktemp "${TMPDIR:-/tmp}/dotsync-conflict.log.XXXXXX")

  mkdir -p "$tmp_home/.local/bin"
  ln -s "$DOTFILE_DIR/common/.local/bin/zk" "$tmp_home/.local/bin/zk"

  if HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >"$conflict_log" 2>&1; then
    echo "expected dotsync to fail when stow sees an existing non-stow link" >&2
    cat "$conflict_log" >&2
    rm -f "$conflict_log"
    rm -rf "$tmp_home"
    exit 1
  fi

  if ! grep -Eiq 'existing target|not owned by stow|conflict' "$conflict_log"; then
    echo "dotsync failed, but not with a recognized stow conflict message" >&2
    cat "$conflict_log" >&2
    rm -f "$conflict_log"
    rm -rf "$tmp_home"
    exit 1
  fi

  rm -f "$conflict_log"
  rm -rf "$tmp_home"
}

# check_script_syntax: syntax-check one script with the interpreter its
# shebang names. One file per invocation: `sh -n a b` and `zsh -n a b` parse
# only `a` and treat `b` as a positional argument, so batching silently skips
# every file after the first.
check_script_syntax() {
  case "$(head -n 1 "$1")" in
    *zsh*) zsh -n -- "$1" ;;
    *) sh -n -- "$1" ;;
  esac
}

# Glob every script rather than listing them: a hand-maintained list drifts
# (uninstall.zsh was missing from it for months).
run_syntax_test() {
  syntax_status=0
  for script in \
      "$DOTFILE_DIR/install.sh" \
      "$DOTFILE_DIR/uninstall.zsh" \
      "$DOTFILE_DIR/common/.local/bin/dotsync" \
      "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/*.zsh "$SCRIPT_DIR"/lib/*.sh; do
    [ -f "$script" ] || continue
    if ! check_script_syntax "$script"; then
      echo "syntax check failed: $script" >&2
      syntax_status=1
    fi
  done
  return "$syntax_status"
}

# Guard check_script_syntax itself: a broken file of each dialect must be
# rejected, and a zsh-only construct must pass (proves shebang dispatch, since
# sh -n would reject it).
run_syntax_selfcheck_test() {
  tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/check-syntax.XXXXXX")
  selfcheck_status=0

  printf '#!/bin/sh\nif then fi\n' >"$tmp_dir/broken.sh"
  if check_script_syntax "$tmp_dir/broken.sh" 2>/dev/null; then
    echo "syntax selfcheck: broken sh file passed" >&2
    selfcheck_status=1
  fi

  # `if then fi` is valid zsh, so use an unclosed paren to break the parse.
  printf '#!/usr/bin/env zsh\n(((\n' >"$tmp_dir/broken.zsh"
  if check_script_syntax "$tmp_dir/broken.zsh" 2>/dev/null; then
    echo "syntax selfcheck: broken zsh file passed" >&2
    selfcheck_status=1
  fi

  printf '#!/usr/bin/env zsh\nfunction is-zsh-only {}\n' >"$tmp_dir/zsh-only.sh"
  if ! check_script_syntax "$tmp_dir/zsh-only.sh" 2>/dev/null; then
    echo "syntax selfcheck: zsh shebang not dispatched to zsh -n" >&2
    selfcheck_status=1
  fi

  rm -rf "$tmp_dir"
  return "$selfcheck_status"
}

run_syntax_selfcheck_test
run_syntax_test
run_sourced_lib_test
"$SCRIPT_DIR/verify-home-manager-hosts.sh"
run_dotsync_smoke_test
run_repo_relative_link_test
run_stow_conflict_test
