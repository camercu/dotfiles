#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd -P)
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

# begin_test NAME: name the running test (for the on_exit banner) and clear
# any log left by the previous test. Clearing here means a test that emits
# straight to stderr never has to remember to reset LAST_LOG — omitting the
# reset used to make on_exit dump an unrelated test's log.
begin_test() {
  CURRENT_TEST=$1
  LAST_LOG=
}

# capture_log: for tests that redirect a command's output into "$LAST_LOG".
# mktemp a log named from the current test and register it for cleanup.
capture_log() {
  LAST_LOG=$(mktemp "${TMPDIR:-/tmp}/check-bootstrap-${CURRENT_TEST}.XXXXXX")
  register_cleanup "$LAST_LOG"
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

# rel_path TARGET START: TARGET expressed relative to START, as stow computes
# its symlink targets.
rel_path() {
  python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$2"
}

# Every entry point into the logging functions must emit the same message for
# the same call: the POSIX script lib, the zsh startup lib, and the
# .bash_aliases copy interactive shells load. They began as three hand-synced
# copies and had already drifted (debug aliased info in two of them, the zsh
# lib had no info at all). Stowing into a scratch HOME first, because the
# interactive copies resolve the shared lib through $HOME.
run_logging_parity_test() {
  begin_test logging_parity_test
  capture_log

  tmp_home=$(CDPATH='' cd -- "$(mktemp -d "${TMPDIR:-/tmp}/logging-parity.XXXXXX")" && pwd -P)
  register_cleanup "$tmp_home"
  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >"$LAST_LOG" 2>&1

  calls='info msg; debug msg; warn msg; error msg; success msg'

  HOME="$tmp_home" sh -c \
    ". \"$SCRIPT_DIR/lib/logging.sh\"; $calls" \
    >/dev/null 2>"$tmp_home/out.posix"
  HOME="$tmp_home" zsh -c \
    "source \"$ZSH_CONFIG_DIR/lib/env-checks.zsh\"
     source \"$ZSH_CONFIG_DIR/lib/logging.zsh\"; $calls" \
    >/dev/null 2>"$tmp_home/out.zsh"
  HOME="$tmp_home" bash -c \
    ". \"$tmp_home/.bash_aliases\"; $calls" \
    >/dev/null 2>"$tmp_home/out.bash"

  # Color is a TTY affordance: piped or captured output (logs, CI) must carry
  # the level in the prefix alone, with no escape sequences to strip.
  if LC_ALL=C grep -lq "$(printf '\033')" "$tmp_home"/out.*; then
    echo "logging: escape sequences emitted when stderr is not a TTY" >&2
    LC_ALL=C grep -l "$(printf '\033')" "$tmp_home"/out.* >&2
    exit 1
  fi

  for variant in zsh bash; do
    if ! cmp "$tmp_home/out.posix" "$tmp_home/out.$variant"; then
      echo "logging: $variant output differs from the POSIX lib" >&2
      exit 1
    fi
  done

  # A level whose prefix duplicates another's cannot be told apart once color
  # is gone, which is exactly how debug hid behind info.
  if [ "$(cut -d' ' -f1 <"$tmp_home/out.posix" | sort -u | wc -l)" -ne 5 ]; then
    echo "logging: levels do not have distinct prefixes" >&2
    cat "$tmp_home/out.posix" >&2
    exit 1
  fi

  # The message helper's scratch variables must not outlive the call. Sourced
  # into an interactive shell, an unscoped assignment leaves the last message's
  # prefix and color sitting in the user's namespace. The cached _LOG_* colors
  # are deliberately global and are not covered here.
  #
  # SC2016: the expansions inside must survive this shell verbatim — the probe
  # is source text for the shell under test, expanded there, not here.
  # shellcheck disable=SC2016
  probe='info msg 2>/dev/null
         printf "%s %s\n" "${__log_prefix-unset}" "${__log_color-unset}"'
  for variant in posix zsh bash; do
    case $variant in
      posix) leaked=$(HOME="$tmp_home" sh -c \
        ". \"$SCRIPT_DIR/lib/logging.sh\"; $probe") ;;
      zsh) leaked=$(HOME="$tmp_home" zsh -c \
        "source \"$ZSH_CONFIG_DIR/lib/logging.zsh\"; $probe") ;;
      bash) leaked=$(HOME="$tmp_home" bash -c \
        ". \"$tmp_home/.bash_aliases\"; $probe") ;;
    esac
    if [ "$leaked" != "unset unset" ]; then
      echo "logging: $variant leaked helper state after a call: $leaked" >&2
      exit 1
    fi
  done
}

run_dotsync_smoke_test() {
  begin_test dotsync_smoke_test
  capture_log

  # Resolve to the physical path: on macOS $TMPDIR lives under /var -> /private/var,
  # and stow resolves that symlink when computing relative links. Fabricating the
  # pre-existing link from the unresolved path yields a target stow would never
  # create, so stow rejects it as "not owned by stow". Resolving keeps the
  # simulated link identical to a real stow-owned one.
  tmp_home=$(CDPATH='' cd -- "$(mktemp -d "${TMPDIR:-/tmp}/dotsync-home.XXXXXX")" && pwd -P)
  register_cleanup "$tmp_home"
  rel_target=$(rel_path "$DOTFILE_DIR/common/.bash_aliases" "$tmp_home")

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
  begin_test repo_relative_link_test
  capture_log

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
  begin_test sourced_lib_test
  lib_status=0
  for script in "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/*.zsh "$DOTFILE_DIR/common/.local/bin/dotsync"; do
    [ -f "$script" ] || continue
    libs=$(grep -ohE '(source|\.) "[^"]*lib[^"]*"' "$script" \
      | sed -E 's|.*/([^/"]+)".*|\1|' | sort -u)
    # Fed through a here-doc rather than a pipe so the loop runs in this shell
    # and its lib_status assignment survives; a piped while would set it in a
    # subshell and the harness would never see the failure.
    while IFS= read -r lib; do
      [ -n "$lib" ] || continue
      if [ ! -f "$SCRIPT_DIR/lib/$lib" ] \
          && [ ! -f "$ZSH_CONFIG_DIR/lib/$lib" ]; then
        echo "$script references missing lib file $lib" >&2
        lib_status=1
      fi
    done <<EOF
$libs
EOF
  done
  return "$lib_status"
}

# Interactive startup must be silent: any output means a config file or an
# eval'd tool hook errored (e.g. compdef called before compinit defines it).
run_zsh_startup_test() {
  begin_test zsh_startup_test
  capture_log

  ZDOTDIR="$ZSH_CONFIG_DIR" zsh -ic 'exit' >"$LAST_LOG" 2>&1 </dev/null
  if [ -s "$LAST_LOG" ]; then
    echo "interactive zsh startup produced output:" >&2
    exit 1
  fi
}

# zsh-health only runs by hand in an interactive shell, so nothing catches a
# regression in it. Drive it against the real config (a broken zsh config
# file fails check-bootstrap) and against fixture ZDOTDIRs proving it can
# still tell healthy from broken.
run_zsh_health_test() {
  begin_test zsh_health_test
  capture_log

  # zsh-health assumes the interactive environment: logging + is-installed
  # loaded, functions/ on fpath. Recreate that around the target ZDOTDIR.
  #
  # SC2016: single quotes on purpose — $ZSH_CONFIG_DIR and $fpath are expanded
  # by the zsh under test (which gets ZSH_CONFIG_DIR in its environment below),
  # not here.
  # shellcheck disable=SC2016
  zsh_health_cmd='
    source "$ZSH_CONFIG_DIR/lib/env-checks.zsh"
    source "$ZSH_CONFIG_DIR/lib/logging.zsh"
    fpath=("$ZSH_CONFIG_DIR/functions" $fpath)
    autoload -Uz zsh-health
    zsh-health'

  # Copied to a local first: assigning ZSH_CONFIG_DIR in the same command
  # prefix that reads it is legal but reads as self-referential (and trips
  # SC2097/SC2098) — both values come from the harness's outer variable.
  real_zdotdir=$ZSH_CONFIG_DIR
  if ! ZDOTDIR="$real_zdotdir" ZSH_CONFIG_DIR="$ZSH_CONFIG_DIR" \
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

# uninstall.zsh prunes broken symlinks that point into this repo. It must
# remove exactly those: not foreign broken links, not healthy repo links.
# Stow creates *relative* links, so the relative case is the primary one.
run_stale_link_prune_test() {
  begin_test stale_link_prune_test
  capture_log

  # Physical path, as with the dotsync smoke test: stow computes relative
  # targets from the physical location, and the fixture must match.
  tmp_home=$(CDPATH='' cd -- "$(mktemp -d "${TMPDIR:-/tmp}/stale-prune-home.XXXXXX")" && pwd -P)
  register_cleanup "$tmp_home"
  mkdir -p "$tmp_home/.config/nested"

  rel_stale=$(rel_path "$DOTFILE_DIR/common/.config/also-no-such-file" "$tmp_home/.config/nested")

  ln -s "$DOTFILE_DIR/common/.config/no-such-file" "$tmp_home/.config/nested/repo-stale"
  ln -s "$rel_stale" "$tmp_home/.config/nested/repo-stale-rel"
  ln -s "../../.dotfiles-elsewhere/gone" "$tmp_home/.config/foreign-stale"
  ln -s "$DOTFILE_DIR/common/.bash_aliases" "$tmp_home/.bash_aliases"

  HOME="$tmp_home" zsh "$DOTFILE_DIR/uninstall.zsh" </dev/null >"$LAST_LOG" 2>&1

  [ ! -L "$tmp_home/.config/nested/repo-stale" ]
  [ ! -L "$tmp_home/.config/nested/repo-stale-rel" ]
  [ -L "$tmp_home/.config/foreign-stale" ]
  [ -L "$tmp_home/.bash_aliases" ]
}

# The prune must be best-effort: one link it cannot remove (unwritable parent)
# must not abort the sweep and strand the rest. The unremovable link sorts
# before the removable one ("locked" < "nested"), so a fail-fast prune would
# never reach the removable link.
run_stale_link_besteffort_test() {
  begin_test stale_link_besteffort_test
  capture_log

  tmp_home=$(CDPATH='' cd -- "$(mktemp -d "${TMPDIR:-/tmp}/stale-besteffort-home.XXXXXX")" && pwd -P)
  register_cleanup "$tmp_home"
  mkdir -p "$tmp_home/.config/locked" "$tmp_home/.config/nested"

  ln -s "$DOTFILE_DIR/common/.config/gone-locked" "$tmp_home/.config/locked/repo-stale"
  ln -s "$DOTFILE_DIR/common/.config/gone-nested" "$tmp_home/.config/nested/repo-stale"
  chmod a-w "$tmp_home/.config/locked"

  HOME="$tmp_home" zsh "$DOTFILE_DIR/uninstall.zsh" </dev/null >"$LAST_LOG" 2>&1

  # Restore write before asserting so the EXIT-trap cleanup can recurse in.
  chmod u+rwx "$tmp_home/.config/locked"

  # The removable link past the failure point is gone: the sweep continued.
  [ ! -L "$tmp_home/.config/nested/repo-stale" ]
  # Root ignores the directory permission, so only assert the block took
  # effect when it actually can.
  if [ "$(id -u)" -ne 0 ]; then
    [ -L "$tmp_home/.config/locked/repo-stale" ]
  fi
}

run_stow_conflict_test() {
  begin_test stow_conflict_test
  capture_log

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

# .bash_aliases is the one file every interactive session loads, so a
# regression there greets the user in every new terminal. Source it in bash
# against a scratch HOME and read back the alias table and the environment,
# once per platform branch (OSTYPE drives the is-macos/is-linux split, so
# forcing it exercises the Linux half from a Mac and vice versa).
run_bash_aliases_test() {
  begin_test bash_aliases_test
  capture_log

  tmp_home=$(CDPATH='' cd -- "$(mktemp -d "${TMPDIR:-/tmp}/bash-aliases.XXXXXX")" && pwd -P)
  register_cleanup "$tmp_home"
  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >"$LAST_LOG" 2>&1

  aliases_status=0

  for platform in darwin24 linux-gnu; do
    HOME="$tmp_home" bash -c \
      "OSTYPE=$platform; . \"\$HOME/.bash_aliases\"; alias" \
      >"$tmp_home/alias.$platform" 2>"$tmp_home/err.$platform"

    # Startup must be silent: probing for a file that only exists on the other
    # platform (/proc/version, /etc/os-release) is expected to come up empty,
    # not to print to the user's terminal.
    if [ -s "$tmp_home/err.$platform" ]; then
      echo "bash_aliases: $platform startup wrote to stderr" >&2
      cat "$tmp_home/err.$platform" >&2
      aliases_status=1
    fi

    # The public-IP lookup is not the ip(8) command; one name for both means
    # whichever branch runs last wins and the other meaning disappears.
    if ! grep -q "^alias myip=" "$tmp_home/alias.$platform"; then
      echo "bash_aliases: $platform defines no myip alias" >&2
      aliases_status=1
    fi
    if grep -q "^alias ip=.*dig" "$tmp_home/alias.$platform"; then
      echo "bash_aliases: $platform aliases ip to the public-IP lookup" >&2
      aliases_status=1
    fi
  done

  if ! grep -qE "^alias ip='ip -{1,2}color=auto'" "$tmp_home/alias.linux-gnu"; then
    echo "bash_aliases: linux does not colorize ip(8)" >&2
    aliases_status=1
  fi

  # Aliases that rename a command must check that the command is there: fd is
  # fdfind only on Debian, and aliasing it blind shadows a real fd binary.
  if ! command -v fdfind >/dev/null 2>&1 &&
      grep -q "^alias fd=" "$tmp_home/alias.linux-gnu"; then
    echo "bash_aliases: aliases fd to fdfind that is not installed" >&2
    aliases_status=1
  fi

  # zsh exports the XDG variables; bash sessions must pass them to child
  # processes too, or tools launched from a bash shell read different paths.
  # env -u so the harness's own exported XDG variables cannot pass this for
  # the file under test.
  for xdg_var in XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME; do
    if ! env -u XDG_CACHE_HOME -u XDG_CONFIG_HOME -u XDG_DATA_HOME \
        -u XDG_STATE_HOME HOME="$tmp_home" bash -c \
        ". \"\$HOME/.bash_aliases\"; env" | grep -q "^$xdg_var="; then
      echo "bash_aliases: $xdg_var is not exported" >&2
      aliases_status=1
    fi
  done

  return "$aliases_status"
}

# check_script_syntax FILE [INTERPRETER]: syntax-check one script with the
# interpreter its shebang names, or with INTERPRETER for the sourced files that
# have no shebang to name one. One file per invocation: `sh -n a b` and
# `zsh -n a b` parse only `a` and treat `b` as a positional argument, so
# batching silently skips every file after the first.
check_script_syntax() {
  if [ -n "${2:-}" ]; then
    "$2" -n -- "$1"
    return
  fi
  case "$(head -n 1 "$1")" in
    *zsh*) zsh -n -- "$1" ;;
    *) sh -n -- "$1" ;;
  esac
}

# Glob every script rather than listing them: a hand-maintained list drifts
# (uninstall.zsh was missing from it for months).
run_syntax_test() {
  begin_test syntax_test
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

  # .bash_aliases has no shebang (it is sourced, never run) and is bash/zsh
  # dialect, so `sh -n` would reject it on a dash-as-sh host. A break here
  # reaches every new terminal, and without this the harness only catches it
  # further along, as a puzzling logging-parity failure.
  if ! check_script_syntax "$DOTFILE_DIR/common/.bash_aliases" bash; then
    echo "syntax check failed: common/.bash_aliases" >&2
    syntax_status=1
  fi

  return "$syntax_status"
}

# Syntax checks only prove a script parses. shellcheck catches the rest —
# unquoted expansions, sourced libs that moved, aliases that expand at the
# wrong time — and a repo that is clean today drifts back the moment nothing
# measures it. Skipped (loudly) rather than failed when shellcheck is absent:
# this harness runs during bootstrap, before any tooling is installed.
#
# -x follows sourced files, so the source directives in the scripts are part
# of what is being checked here.
run_shellcheck_test() {
  begin_test shellcheck_test

  if ! command -v shellcheck >/dev/null 2>&1; then
    echo "shellcheck: not installed, skipping static analysis" >&2
    return 0
  fi

  capture_log
  shellcheck_status=0

  # -s bash for the shebang-less sourced file, matching the syntax pass.
  if ! shellcheck -x -s bash "$DOTFILE_DIR/common/.bash_aliases" >"$LAST_LOG" 2>&1; then
    shellcheck_status=1
  fi

  for script in \
      "$DOTFILE_DIR/install.sh" \
      "$DOTFILE_DIR/common/.local/bin/dotsync" \
      "$DOTFILE_DIR"/common/.config/claude/hooks/*.sh \
      "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/lib/*.sh; do
    [ -f "$script" ] || continue
    if ! shellcheck -x "$script" >>"$LAST_LOG" 2>&1; then
      shellcheck_status=1
    fi
  done

  if [ "$shellcheck_status" -ne 0 ]; then
    echo "shellcheck: findings in the shell sources" >&2
  fi
  return "$shellcheck_status"
}

# Guard check_script_syntax itself: a broken file of each dialect must be
# rejected, and a zsh-only construct must pass (proves shebang dispatch, since
# sh -n would reject it).
run_syntax_selfcheck_test() {
  begin_test syntax_selfcheck_test
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

  # An explicit interpreter must win over the shebang guess, which is the
  # whole point of the argument: shebang-less sourced files are not sh.
  printf 'if then fi\n' >"$tmp_dir/broken-noshebang"
  if check_script_syntax "$tmp_dir/broken-noshebang" bash 2>/dev/null; then
    echo "syntax selfcheck: broken shebang-less file passed" >&2
    selfcheck_status=1
  fi

  printf 'greet() { echo "hi" >&2; }\n' >"$tmp_dir/sourced-noshebang"
  if ! check_script_syntax "$tmp_dir/sourced-noshebang" bash 2>/dev/null; then
    echo "syntax selfcheck: valid shebang-less file rejected" >&2
    selfcheck_status=1
  fi

  return "$selfcheck_status"
}

run_syntax_selfcheck_test
run_syntax_test
run_shellcheck_test
run_sourced_lib_test
begin_test verify_home_manager_hosts
"$SCRIPT_DIR/verify-home-manager-hosts.sh"
run_zsh_startup_test
run_zsh_health_test
run_stale_link_prune_test
run_stale_link_besteffort_test
run_dotsync_smoke_test
run_logging_parity_test
run_bash_aliases_test
run_repo_relative_link_test
run_stow_conflict_test

echo "check-bootstrap: all checks passed"
