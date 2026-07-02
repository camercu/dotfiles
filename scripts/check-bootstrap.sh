#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
ZSH_CONFIG_DIR="$DOTFILE_DIR/common/.config/zsh"

# set -e aborts on the first failed assertion, which by itself prints
# nothing. Track the running test, its captured command output, and every
# tmp path, so the EXIT trap can name the failure, dump the log, and clean
# up even when a test dies mid-way.
CURRENT_TEST=startup
LAST_LOG=
CLEANUP_PATHS=

register_cleanup() {
  CLEANUP_PATHS="$CLEANUP_PATHS
$1"
}

on_exit() {
  exit_status=$?
  if [ "$exit_status" -ne 0 ]; then
    echo "check-bootstrap: FAILED in $CURRENT_TEST (exit $exit_status)" >&2
    if [ -n "$LAST_LOG" ] && [ -s "$LAST_LOG" ]; then
      echo "--- captured output:" >&2
      cat "$LAST_LOG" >&2
    fi
  fi
  IFS='
'
  for cleanup_path in $CLEANUP_PATHS; do
    rm -rf "$cleanup_path"
  done
}
trap on_exit EXIT

resolve_path() {
  python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

run_dotsync_smoke_test() {
  CURRENT_TEST=dotsync_smoke_test
  LAST_LOG=$(mktemp "${TMPDIR:-/tmp}/dotsync-smoke.log.XXXXXX")
  register_cleanup "$LAST_LOG"

  # Resolve to the physical path: on macOS $TMPDIR lives under /var -> /private/var,
  # and stow resolves that symlink when computing relative links. Fabricating the
  # pre-existing link from the unresolved path yields a target stow would never
  # create, so stow rejects it as "not owned by stow". Resolving keeps the
  # simulated link identical to a real stow-owned one.
  tmp_home=$(CDPATH= cd -- "$(mktemp -d "${TMPDIR:-/tmp}/dotsync-home.XXXXXX")" && pwd -P)
  register_cleanup "$tmp_home"
  rel_target=$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' \
    "$DOTFILE_DIR/common/.bash_aliases" "$tmp_home")

  ln -s "$rel_target" "$tmp_home/.bash_aliases"

  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >"$LAST_LOG" 2>&1
  [ -L "$tmp_home/.bash_aliases" ]
  [ "$(resolve_path "$tmp_home/.bash_aliases")" = "$(resolve_path "$DOTFILE_DIR/common/.bash_aliases")" ]

  HOME="$tmp_home" "$SCRIPT_DIR/uninstall-dotfiles.sh" >"$LAST_LOG" 2>&1
  [ ! -L "$tmp_home/.bash_aliases" ]

  ln -s "$rel_target" "$tmp_home/.bash_aliases"
  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" --auto-discover >"$LAST_LOG" 2>&1
  [ -L "$tmp_home/.bash_aliases" ]
  [ "$(resolve_path "$tmp_home/.bash_aliases")" = "$(resolve_path "$DOTFILE_DIR/common/.bash_aliases")" ]
}

run_repo_relative_link_test() {
  CURRENT_TEST=repo_relative_link_test
  LAST_LOG=$(mktemp "${TMPDIR:-/tmp}/dotsync-repo-rel.log.XXXXXX")
  register_cleanup "$LAST_LOG"

  # Deliberately inside the repo: exercises the relative links stow computes
  # when $HOME lives under the dotfile dir. Pattern is gitignored in case a
  # failure leaves it behind.
  tmp_home=$(mktemp -d "$DOTFILE_DIR/.tmp-dotsync-home.XXXXXX")
  register_cleanup "$tmp_home"

  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >"$LAST_LOG" 2>&1
  [ -L "$tmp_home/.bash_aliases" ]
  [ "$(resolve_path "$tmp_home/.bash_aliases")" = "$(resolve_path "$DOTFILE_DIR/common/.bash_aliases")" ]

  HOME="$tmp_home" "$SCRIPT_DIR/uninstall-dotfiles.sh" >"$LAST_LOG" 2>&1
}

# `sh -n`/`zsh -n` never resolve `source` targets, so a script pointing at a
# deleted lib still passes syntax checks and only breaks at runtime (silently,
# when nothing sets -e). Assert every lib/<file> referenced by a script exists
# in one of the two lib trees: scripts/lib (install scripts) or the zsh config
# lib (referenced by this harness's zsh-health fixture).
run_sourced_lib_test() {
  CURRENT_TEST=sourced_lib_test
  LAST_LOG=
  lib_status=0
  for script in "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/*.zsh "$DOTFILE_DIR/common/.local/bin/dotsync"; do
    [ -f "$script" ] || continue
    for lib in $(grep -ohE '(source|\.) "[^"]*lib[^"]*"' "$script" \
        | sed -E 's|.*/([^/"]+)".*|\1|' | sort -u); do
      if [ ! -f "$SCRIPT_DIR/lib/$lib" ] \
          && [ ! -f "$ZSH_CONFIG_DIR/lib/$lib" ]; then
        echo "$script references missing lib file $lib" >&2
        lib_status=1
      fi
    done
  done
  return "$lib_status"
}

# zsh-health only runs by hand in an interactive shell, so nothing catches a
# regression in it. Drive it against the real config (a broken zsh config
# file fails check-bootstrap) and against fixture ZDOTDIRs proving it can
# still tell healthy from broken.
run_zsh_health_test() {
  CURRENT_TEST=zsh_health_test
  LAST_LOG=$(mktemp "${TMPDIR:-/tmp}/zsh-health.log.XXXXXX")
  register_cleanup "$LAST_LOG"

  # zsh-health assumes the interactive environment: logging + is-installed
  # loaded, functions/ on fpath. Recreate that around the target ZDOTDIR.
  zsh_health_cmd='
    source "$ZSH_CONFIG_DIR/lib/env-checks.zsh"
    source "$ZSH_CONFIG_DIR/lib/logging.zsh"
    fpath=("$ZSH_CONFIG_DIR/functions" $fpath)
    autoload -Uz zsh-health
    zsh-health'

  if ! ZDOTDIR="$ZSH_CONFIG_DIR" ZSH_CONFIG_DIR="$ZSH_CONFIG_DIR" \
      zsh -c "$zsh_health_cmd" >"$LAST_LOG" 2>&1; then
    echo "zsh-health: real zsh config failed the health check" >&2
    exit 1
  fi

  fixture=$(mktemp -d "${TMPDIR:-/tmp}/zsh-health-fixture.XXXXXX")
  register_cleanup "$fixture"
  mkdir -p "$fixture/lib"
  printf '# fixture zshrc\n' >"$fixture/.zshrc"

  if ! ZDOTDIR="$fixture" ZSH_CONFIG_DIR="$ZSH_CONFIG_DIR" \
      zsh -c "$zsh_health_cmd" >"$LAST_LOG" 2>&1; then
    echo "zsh-health: healthy fixture config failed" >&2
    exit 1
  fi

  printf '(((\n' >"$fixture/lib/broken.zsh"
  if ZDOTDIR="$fixture" ZSH_CONFIG_DIR="$ZSH_CONFIG_DIR" \
      zsh -c "$zsh_health_cmd" >"$LAST_LOG" 2>&1; then
    echo "zsh-health: config with broken lib file passed" >&2
    exit 1
  fi
}

run_stow_conflict_test() {
  CURRENT_TEST=stow_conflict_test
  LAST_LOG=$(mktemp "${TMPDIR:-/tmp}/dotsync-conflict.log.XXXXXX")
  register_cleanup "$LAST_LOG"

  tmp_home=$(mktemp -d "${TMPDIR:-/tmp}/dotsync-conflict.XXXXXX")
  register_cleanup "$tmp_home"

  mkdir -p "$tmp_home/.local/bin"
  ln -s "$DOTFILE_DIR/common/.local/bin/zk" "$tmp_home/.local/bin/zk"

  if HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >"$LAST_LOG" 2>&1; then
    echo "expected dotsync to fail when stow sees an existing non-stow link" >&2
    exit 1
  fi

  if ! grep -Eiq 'existing target|not owned by stow|conflict' "$LAST_LOG"; then
    echo "dotsync failed, but not with a recognized stow conflict message" >&2
    exit 1
  fi
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
  CURRENT_TEST=syntax_test
  LAST_LOG=
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
  CURRENT_TEST=syntax_selfcheck_test
  LAST_LOG=
  tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/check-syntax.XXXXXX")
  register_cleanup "$tmp_dir"
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

  return "$selfcheck_status"
}

run_syntax_selfcheck_test
run_syntax_test
run_sourced_lib_test
CURRENT_TEST=verify_home_manager_hosts
LAST_LOG=
"$SCRIPT_DIR/verify-home-manager-hosts.sh"
run_zsh_health_test
run_dotsync_smoke_test
run_repo_relative_link_test
run_stow_conflict_test

echo "check-bootstrap: all checks passed"
