# Record as you go

Applies to any review, audit, survey, or exploratory pass that produces
findings. Context dies mid-pass (session limit, compaction, crash); findings
held in context die with it. File on disk survives.

1. Open the findings file before the first probe. Header: target, scope
   (commit range or paths), date, mode.
2. Append each finding before the next probe starts, with its evidence:
   command, output, `file:line`.
3. Record cleared hazards and declined candidates too, each with the reason. A
   cleared result stops the next pass re-deriving it.
4. Findings file, repro code and commands live under `.scratch/<skill>/`
   (AGENTS.md *Working files*); the file references repros by path, so a
   later run rebuilds them.
5. Delegated pass: its prompt names the findings-file path and step 2. The file
   is the deliverable; the returned summary points at it. Agent died → harvest
   its file, relaunch for the remainder only.

Done when every finding and every cleared hazard of the pass is in the file,
and the chat summary gives the file's path.
