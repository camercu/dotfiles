# RTK - Rust Token Killer

**Usage**: token-optimized CLI proxy (60-90% savings on dev ops)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: if `rtk gain` fails, may have reachingforthejack/rtk (Rust Type Kit) instead.

## Hook-Based Usage

All other commands auto-rewritten by the Claude Code hook. E.g. `git status` →
`rtk git status` (transparent, 0 token overhead).

**Hook rewrites STANDALONE commands only.** Compound (`a && git log`,
`a; grep -n`, pipes) bypass rtk → full-fat output. Prefer separate standalone
Bash calls over `;`/`&&` chains when output big (git log/diff, grep, cargo
test). Chain fine when output tiny.

**`just` recipes bypass rtk too** — recipe body runs cargo directly, hook never
sees it. Repos seeded from `rust-template` (blivet, litmask, relentless) carry
`cargo := env("RTK_CARGO","cargo")` + a `ci-rtk` recipe. Use `ci-rtk` for
quick feedback. For the authoritative gate, run `env -u RTK_CARGO just ci`
in the project environment and capture its full log and status.
Recipes deliberately left on plain cargo — stable-channel (`+stable`),
coverage-lcov, `public-api*`, tool-version checks — rtk corrupts
file-written/parsed output or toolchain-pinned runs. Don't "fix" those.

**rtk masks child exit codes** and filters some build-script panics. Follow
AGENTS.md *Authoritative verification* for the commit gate. RTK keeps its
own logs under `~/Library/Application Support/rtk/tee/`.

Full command reference: CLAUDE.md.
