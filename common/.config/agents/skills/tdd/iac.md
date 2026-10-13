# TDD for infrastructure code

Goal: tests sit where infrastructure code breaks: logic, rendered config, and
outcomes on the real host. Declarative YAML is its own spec. A test that
restates it goes red only on an intended edit, so it costs upkeep and catches
nothing.

## Classify each changed file first

Every file in `git diff --name-only` gets one row:

| Change | Test it gets |
|---|---|
| Logic: filter or lookup plugin, module, script, template with loops or conditionals | Double loop from SKILL.md, then mutation pass |
| Rendered config a daemon parses: nftables, sshd, systemd unit, Quadlet, proxy config | Native validator on the render, in CI: `nft -c -f`, `sshd -t -f`, `systemd-analyze verify`, `/usr/libexec/podman/quadlet -dryrun`, the proxy's own check |
| Desired host state: listener, reachability, refusal, permission, unit health | Outcome assertion in the on-host verify playbook |
| Plain declaration matching none above: package list, file mode, sysctl value | Covered by idempotence and check-mode diff; commit body line `Validated by: <check>` |

## Outer loop: outcome first

Acceptance test = outcome assertion in the verify playbook, run against the
real target. Write it first, run it, see it red on the host, then build until
green. Host not reachable yet → run in check mode, and record the assertion as
pending first host run. Assert what a user or attacker observes: port answers,
certificate chain, request refused, egress rejected, unit healthy.

Every role gets two checks with no extra code: a second converge reports
`changed=0`, and check mode runs clean before apply.

## Inner loop: logic only

Unit tests drive logic through its public interface: call the filter with
data, run the script with arguments, render a branching template and assert
its output. A module runs for real against a real or ephemeral target.

## Value bar

Each test names the mistake class it catches. Answer "someone edited the YAML
on purpose" → delete the test. Test that reads config text: read
`~/.config/agents/guard-ladders.md`, *Test guards*, first.

Offline component tests (Molecule, container converge) keep their place only
while they catch what validators and verify miss. Time-box them and record
runtime.

## Done criterion

Done when every changed file has a row, each row's test exists and ran green
(verify on the host, or recorded as pending first host run), and each
plain-declaration commit carries its `Validated by:` line.

## Self-check

1. `git diff --name-only` → each path maps to a row. Unmapped path → classify.
2. Each test → name its mistake class. No answer → delete.
3. Each new verify assertion → red observed before green, or recorded pending.
