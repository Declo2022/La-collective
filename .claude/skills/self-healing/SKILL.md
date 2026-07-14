---
name: self-healing
description: >-
  Detect, diagnose, and automatically fix failures in a codebase — failing
  tests, lint/type errors, broken builds, and runtime exceptions — then verify
  the fix. Use when the user says "self heal", "auto-fix", "make it green", "fix
  the failing tests/build/CI", or after a command fails and the user wants it
  repaired without manual back-and-forth.
---

# Self-Healing

Drive a broken state back to green: reproduce the failure, find the root cause,
apply the smallest correct fix, and verify. Loop until the target passes or you
hit a genuine blocker you must escalate.

## Core loop

Repeat this cycle for each failure until the target is green or you're blocked:

1. **Reproduce.** Run the exact failing command (test, build, lint, type-check,
   or the app itself) and capture the real output. Never fix from memory of what
   "should" be wrong — read the actual error.
2. **Localize.** Read the stack trace / error and open the file and line it
   points to. Trace back to the true source, not just where the symptom surfaced.
3. **Diagnose.** State the root cause in one sentence before touching code. If
   you can't, gather more signal (logs, a narrower repro, `git blame`/recent
   diff) instead of guessing.
4. **Fix minimally.** Apply the smallest change that addresses the root cause.
   Prefer fixing the bug over deleting the assertion, loosening the type, or
   `try/except`-swallowing the error.
5. **Verify.** Re-run the same command. If green, move to the next failure. If
   still red, compare new output to old — did anything change? — and iterate.
6. **Guard against regressions.** Before declaring done, run the broader suite
   (full tests + lint + type-check + build) so one fix didn't break another.

## Rules that keep fixes honest

- **Fix the cause, not the check.** Do not make a test pass by weakening or
  removing it, skipping it, or hard-coding its expected value. If a test is
  genuinely wrong, say so explicitly and confirm before changing it.
- **One failure at a time.** Isolate and fix distinct root causes separately so
  each fix is verifiable and revertible.
- **No masking.** Never silence errors with bare catches, `@ts-ignore`,
  `# noqa`, `eslint-disable`, or retries-until-it-passes unless that IS the
  correct fix and you can justify it.
- **Bounded retries.** If the same failure survives ~3 real fix attempts, stop
  and escalate with your diagnosis — don't thrash.
- **Report faithfully.** If tests still fail, say so with the output. Only
  declare "fixed" after a clean verification run.

## Discovering the commands

Find the project's real test/lint/build commands before running arbitrary ones:

- Check `package.json` scripts, `Makefile`, `pyproject.toml`, `justfile`,
  `.github/workflows/*`, or a project `CLAUDE.md`.
- Prefer the command CI runs, so local green matches CI green.
- If no verify skill/command exists, run the narrowest thing that reproduces the
  failure.

## Escalate instead of guessing when

- The fix requires a product/architecture decision (which behavior is correct?).
- The failure is caused by missing secrets, external services, or the
  environment — not the code.
- Repeated fix attempts don't move the error.

In these cases, stop and report: what fails, the root cause you found, what you
tried, and the specific decision or input you need. Use `AskUserQuestion` when a
choice is genuinely the user's to make.

## Common failure playbook

For error-type-specific tactics (flaky tests, import/module errors, type
mismatches, dependency/version conflicts, CI-only failures), read
`references/playbook.md`.
