---
name: skill-creator
description: >-
  Create, structure, and refine Claude Code Skills. Use this whenever the user
  wants to build a new skill, scaffold a SKILL.md, improve an existing skill's
  description or triggers, split a large skill into reference files, or package a
  skill for distribution. Triggers on "create a skill", "new skill", "skill
  creator", "author a skill", "make a skill for X", "write a SKILL.md".
---

# Skill Creator

Guide the user through authoring a high-quality Claude Code Skill. A Skill is a
directory containing a `SKILL.md` file (with YAML frontmatter + Markdown body)
plus any supporting reference files, scripts, or templates it needs.

## What a Skill is

A Skill packages reusable instructions and assets so Claude can perform a
specialized task consistently. Claude discovers a skill from its **description**,
loads the `SKILL.md` body when the skill is invoked, and reads referenced files
only when needed. This progressive disclosure keeps context lean.

Directory layout:

```
.claude/skills/<skill-name>/
├── SKILL.md              # required: frontmatter + instructions
├── references/           # optional: docs Claude reads on demand
│   └── *.md
├── scripts/              # optional: executable helpers
│   └── *.{sh,py,js}
└── assets/               # optional: templates, examples, data
```

## Authoring workflow

Follow these steps when creating a skill:

1. **Clarify the job.** Ask what task the skill automates, what triggers it, and
   what a successful outcome looks like. If the user already gave enough detail,
   skip straight to drafting.
2. **Pick a name.** Lowercase, hyphen-separated, verb-or-noun that names the
   task (e.g. `pdf-extractor`, `release-notes`, `api-client`). It must match the
   directory name.
3. **Write the description first** — it is the single most important field.
   See the rules below.
4. **Draft the body.** Keep it focused and imperative. Tell Claude *what to do*
   and *in what order*, not general background it already knows.
5. **Extract references.** Move anything long, optional, or lookup-oriented into
   `references/*.md` and point to it from the body. Keep `SKILL.md` under a few
   hundred lines.
6. **Add scripts/assets** only if they save tokens or guarantee correctness
   (deterministic transforms, templates, schemas).
7. **Validate** the frontmatter and structure (see checklist).

## Writing the description (most important)

The description is how Claude decides whether to load the skill. Make it
concrete and trigger-rich:

- Start with what the skill *does*, in the third person: "Extract tables from
  PDFs and…".
- Name the **triggers** — the phrases, file types, or situations that should
  activate it. Include the literal words a user might say.
- Keep it to 1–3 sentences. Avoid vague verbs like "helps with" or "manages".
- Do **not** describe *how* it works internally — that belongs in the body.

Good:
> Extract text and tables from PDF files and convert them to Markdown or CSV.
> Use when the user uploads a PDF, mentions "extract from PDF", or asks to turn
> a PDF into structured data.

Weak:
> A helpful skill for working with documents.

## Frontmatter rules

Only two fields are required:

```yaml
---
name: my-skill              # matches directory name, lowercase-hyphenated
description: >-             # trigger-rich, third person, 1–3 sentences
  What it does and when to use it, including literal trigger phrases.
---
```

- `name`: lowercase letters, digits, hyphens only. No spaces.
- `description`: the discovery text. Never leave it generic.
- Keep frontmatter minimal — extra keys are ignored by the loader.

## Body-writing principles

- **Imperative and ordered.** Write steps Claude executes, not prose about the
  domain.
- **Progressive disclosure.** The body is always loaded; reference files are
  read on demand. Put the 20% Claude always needs in the body, the 80% of
  lookup detail in `references/`.
- **Point, don't inline.** Reference a file with a relative path and a one-line
  reason to open it: "For the full field list, read `references/schema.md`."
- **Don't restate model knowledge.** Skip explanations of well-known tools,
  languages, or concepts — focus on the specifics of *this* task.
- **Show the happy path.** Include a concrete example of input → action → output
  when it removes ambiguity.

## Checklist before finishing

- [ ] Directory name matches `name` in frontmatter.
- [ ] `description` names concrete triggers and what the skill does.
- [ ] Body is imperative, ordered, and free of filler.
- [ ] Long/optional material lives in `references/`, linked from the body.
- [ ] Any script is executable and does something Claude can't do reliably inline.
- [ ] `SKILL.md` reads cleanly top-to-bottom for someone who has never seen it.

For a ready-to-copy starting point, read `references/template.md`.
