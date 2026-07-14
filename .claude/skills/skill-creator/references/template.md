# SKILL.md template

Copy this into `.claude/skills/<skill-name>/SKILL.md` and fill it in. Delete the
comments and any section you don't need.

```markdown
---
name: <skill-name>
description: >-
  <What the skill does, third person>. Use when <concrete trigger situations and
  literal phrases the user might say>.
---

# <Skill Title>

<One or two sentences: the goal of this skill and when it applies.>

## Steps

1. <First imperative action.>
2. <Next action, in order.>
3. <…>

## Notes / edge cases

- <Anything that changes the steps: special inputs, failure modes, options.>

## Reference

For <deep detail X>, read `references/<file>.md`.
```

## Minimal example

A skill can be as small as this:

```markdown
---
name: changelog-entry
description: >-
  Add a formatted entry to CHANGELOG.md following Keep a Changelog. Use when the
  user says "add a changelog entry", "update the changelog", or after merging a
  user-facing change.
---

# Changelog Entry

1. Read `CHANGELOG.md` and find the `## [Unreleased]` section.
2. Add the change under the correct subsection (Added / Changed / Fixed /
   Removed), creating it if missing.
3. Write the entry in past tense, one line, referencing the PR or issue number
   when known.
4. Preserve existing formatting and ordering.
```

## When to add subdirectories

- `references/` — field lists, schemas, style guides, long examples Claude reads
  only when it hits that case.
- `scripts/` — deterministic helpers (a Python formatter, a validation script).
  Prefer a script over prose when correctness matters more than flexibility.
- `assets/` — templates, boilerplate files, sample data the skill copies or
  fills in.

Keep everything the skill references inside its own directory so it stays
self-contained and portable.
