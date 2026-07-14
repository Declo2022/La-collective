---
name: superpowers
description: >-
  A disciplined engineering workflow that upgrades how any non-trivial task is
  executed — understand, plan, implement in small verified steps (test-first
  where it fits), and verify against reality before claiming done. Use when the
  user says "use superpowers", "do this properly", "be rigorous", "full
  workflow", or is starting a substantial feature/refactor/bugfix and wants
  disciplined execution rather than a quick patch.
---

# Superpowers

A meta-workflow for doing serious engineering work well. It doesn't replace
domain skills — it sequences them and enforces the discipline that keeps large
changes correct: understand before coding, plan before building, work in small
verifiable steps, and verify against reality before declaring success.

## When to engage

Use the full workflow for anything non-trivial: a new feature, a refactor, a
real bug, or work touching architecture. For a one-line typo fix, skip the
ceremony — just make the change. Judgment over ritual.

## The workflow

### 1. Understand
- Restate the goal in one sentence and confirm success criteria.
- Read the relevant code and surrounding conventions before proposing changes.
- Surface unknowns now. If a decision is genuinely the user's to make, ask with
  `AskUserQuestion` rather than guessing.

### 2. Plan
- Break the work into ordered, independently verifiable steps.
- Identify the files/modules each step touches and the risks.
- For substantial or ambiguous work, present the plan and get agreement before
  building. Prefer plan mode when available.

### 3. Implement in small steps
- Make one coherent change at a time; keep each step verifiable and revertible.
- Match the surrounding code's style, naming, and idioms — read like the
  codebase, don't reinvent it.
- **Test-first where it fits**: for logic with clear inputs/outputs, write the
  failing test, then the code to pass it. Don't force TDD onto pure UI or
  throwaway spikes.
- Reuse what exists (helpers, components, tokens) before adding new abstractions.

### 4. Verify against reality
- Run the actual thing — tests, the app, the flow — not just a type-check.
- After the full change, run the broader suite (tests + lint + types + build) so
  one step didn't break another.
- For UI, view it running; for a fix, reproduce the original failure and confirm
  it's gone.

### 5. Report faithfully
- State what changed, what you verified, and how. If tests fail or a step was
  skipped, say so with the evidence.
- Only declare "done" after a clean verification run. No hedging when it's
  genuinely verified; no false confidence when it isn't.

## Core disciplines (apply throughout)

- **Root cause over symptom.** Fix why it's broken, not just where it surfaced.
  Never make a test pass by weakening or deleting it.
- **Smallest correct change.** Resist scope creep; don't refactor unrelated code
  mid-task unless asked.
- **Reversible history.** Commit coherent units with clear messages; branch off
  the default branch rather than piling onto it.
- **No masking.** Don't silence errors with bare catches, ignores, or
  retries-until-green.
- **Escalate on blockers.** After a bounded number of real attempts, stop and
  report the diagnosis and the decision you need — don't thrash.

## Compose with the other skills

Reach for the right specialist skill at the right phase:

- **Planning something large** → let the Plan phase drive; write the plan down.
- **Building UI** → `frontend-design`.
- **Testing a web app end-to-end** → `web-app-testing`.
- **Something is failing / red** → `self-healing`.
- **Building an MCP server** → `mcp-server`.
- **Authoring a new skill** → `skill-creator`.

Superpowers is the connective tissue: it decides *when* each of these applies
and holds the overall change to a high standard.
