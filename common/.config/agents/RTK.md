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

Full command reference: CLAUDE.md.
