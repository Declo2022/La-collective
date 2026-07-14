---
name: claude-mem
description: >-
  Capture and recall durable project memory across sessions — decisions,
  conventions, gotchas, and context worth remembering — persisted in the repo so
  it survives the ephemeral session. Use when the user says "remember this",
  "claude mem", "save this for later", "note that", "what did we decide about
  X", "recall", or when a hard-won fact or decision should outlive the current
  conversation.
---

# Claude Mem

Persist the things worth remembering so future sessions start informed instead
of relearning. This session's container is ephemeral — only what's committed to
the repo survives. Memory that isn't written down is lost.

## Where memory lives

Store durable memory in the repository, in order of preference:

- **`CLAUDE.md`** (repo root or a subdirectory) — the primary, always-loaded
  memory. Put conventions, architecture notes, commands, and standing
  instructions here. Subdirectory `CLAUDE.md` files scope memory to that area.
- **`.claude/memory/*.md`** — longer-lived notes that don't belong in the
  always-loaded file: decision logs, investigation write-ups, domain glossaries.
  Reference them from `CLAUDE.md` so they're discoverable.

Never store secrets, tokens, or credentials in memory files — they're committed
to the repo.

## What is worth remembering

Capture the durable, reusable, and non-obvious:

- **Decisions and their rationale** — "we chose X over Y because Z" (so it isn't
  relitigated).
- **Conventions** — naming, structure, patterns the codebase follows.
- **Commands** — how to build, test, lint, run, deploy this project.
- **Gotchas** — non-obvious constraints, footguns, "don't touch X because Y".
- **Standing preferences** — how the user wants things done, repeatedly.
- **Glossary** — project-specific terms and what they mean.

Do **not** capture: transient state, one-off task details, anything easily
re-derived, or private/sensitive data.

## Capturing memory

When the user says "remember this" (or you hit a fact clearly worth persisting):

1. **Decide scope.** Repo-wide → root `CLAUDE.md`. Area-specific → that
   directory's `CLAUDE.md`. Long/reference → `.claude/memory/<topic>.md`.
2. **Write it durably.** Phrase it as a standing fact or instruction, not a
   diary entry — future-you has no conversation context. Concise, imperative,
   dated when recency matters.
3. **Place it well.** Add under the right existing heading; create one if none
   fits. Keep the file organized, not append-only sludge.
4. **De-duplicate.** If it updates an existing note, edit that note rather than
   adding a contradicting second copy.
5. **Commit it.** Uncommitted memory dies with the container. Commit with a clear
   message; push if that's the session's workflow.

## Recalling memory

When asked "what did we decide / what's the convention for X / recall":

1. Read `CLAUDE.md` (root and any relevant subdirectory) first.
2. Check `.claude/memory/` for a matching topic file.
3. Answer from what's written; cite the file. If it's not recorded, say so
   plainly rather than inventing — and offer to capture it now.

## Hygiene

- **Keep it current.** When a decision changes, update the note; mark superseded
  entries rather than leaving contradictions.
- **Keep `CLAUDE.md` lean.** It's always loaded — move bulky detail into
  `.claude/memory/` and link to it (progressive disclosure).
- **One source of truth.** Don't fork the same fact across files.

## Relationship to harness config

Memory is *knowledge* ("we use pnpm", "the API base is in config/"). It does not
make Claude *do* things automatically. For automated behaviors ("whenever X,
run Y"), that's a hook in settings — use the `update-config` skill, not a memory
note. If the user asks memory to trigger an action, tell them it needs a hook.
