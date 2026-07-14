# Self-Healing Playbook

Type-specific tactics. Always still follow the core loop (reproduce → localize →
diagnose → fix → verify) — this is a shortcut to the likely root cause, not a
replacement for reading the actual error.

## Failing tests

- Read the assertion message and the actual-vs-expected values first.
- Is the **code** wrong or the **test** wrong? A test encoding intended behavior
  that the code violates → fix the code. A test asserting stale/incorrect
  behavior → confirm with the user before changing it.
- Reproduce a single test in isolation before running the whole suite.

## Flaky / intermittent tests

- Run the test several times to confirm flakiness before "fixing" it.
- Usual causes: shared mutable state between tests, real time/`Date.now()`,
  network calls, unawaited async, ordering dependence, random seeds.
- Fix the source of nondeterminism (inject a clock, mock the network, `await`
  the promise, isolate state) — don't add sleeps or retries.

## Lint / formatting errors

- Run the project's auto-fixer first (`eslint --fix`, `ruff --fix`,
  `prettier --write`, `gofmt`, etc.) — many resolve mechanically.
- For rules that can't auto-fix, address the underlying issue; disable a rule
  inline only when the rule is genuinely wrong for that line, and say why.

## Type errors

- Fix the actual type mismatch — correct the value, the signature, or the
  generic — rather than casting to `any`/`object` or adding `@ts-ignore` /
  `# type: ignore`.
- If a third-party type is wrong, a narrow local cast with a comment is
  acceptable; note it.

## Import / module-not-found

- Confirm the package is installed and in the manifest (`package.json`,
  `requirements.txt`, `pyproject.toml`, `go.mod`).
- Check the path is right (case-sensitive on Linux), the export exists, and it's
  not a circular import.
- Install/lock only if the dependency is genuinely intended — don't paper over a
  wrong import path with a new dependency.

## Build failures

- Read the first error, not the last — later errors are often cascades from the
  first.
- Distinguish config errors (bundler, tsconfig, compiler flags) from source
  errors; fix config once, then re-run.

## Dependency / version conflicts

- Read the resolver's conflict message to see which constraints clash.
- Prefer aligning to the range the project already targets; avoid blanket
  upgrades. Regenerate the lockfile deterministically after any change.

## CI-only failures (green locally, red in CI)

- Likely environment differences: OS/case sensitivity, timezone/locale, Node/
  Python version, missing env vars/secrets, install without dev-deps, or
  parallelism exposing flakiness.
- Reproduce with CI's exact command and, where possible, its versions. Read the
  CI job logs rather than assuming.
- If it's caused by missing secrets or unavailable services, that's an
  environment issue — escalate rather than editing code.

## Runtime exceptions

- Get the full stack trace and the input that triggers it.
- Reproduce with the smallest input, then fix the root cause (null/undefined
  handling, off-by-one, wrong assumption about shape) — not just the throwing
  line.
