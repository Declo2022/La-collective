# Research Methods

Deeper technique for the `researcher` skill.

## Search strategy

- **Start broad, then narrow.** A wide first query maps the space; follow-ups
  drill into the promising branch. Don't over-commit to the first hit.
- **Vary the query.** If one phrasing returns weak results, reformulate with
  synonyms, error text, or the exact API/function name.
- **Codebase sweeps.** Use `Grep` for symbols/strings and `Glob` for file
  patterns. When you need "where is X handled across the repo" and only want the
  conclusion (not every file dumped into context), delegate to the `Explore`
  agent.
- **Follow the trail.** From a search hit, read imports, call sites, and tests
  to understand real usage rather than guessing from a name.

## Source quality tiers

Prefer higher tiers; drop to lower only when nothing better exists, and label
the source's tier implicitly by naming it.

1. **Primary, authoritative** — the source code itself, official docs, RFCs/
   specs, standards, a vendor's own API reference. Trust most.
2. **Primary, first-party** — official blog posts, changelogs, release notes,
   maintainer statements.
3. **Reputable secondary** — well-regarded technical write-ups, established
   references (MDN, language docs), peer-reviewed material.
4. **Community** — Stack Overflow, forum threads, random blogs. Useful for
   leads and gotchas; verify against a primary source before relying on it.
5. **Untrusted** — SEO content, AI-generated summaries, undated pages. Corroborate
   or discard.

## Cross-checking

- Corroborate any load-bearing claim across at least two independent sources.
- When sources conflict, prefer the more authoritative and more recent one, and
  **report the disagreement** rather than silently choosing.
- Watch for circular sourcing — several pages repeating one original (often
  wrong) claim is not independent corroboration.

## Recency discipline

- For versions, pricing, limits, model capabilities, or current events, always
  check the publication/update date and prefer live search over memory.
- State the "as of" date in the answer when the fact can change.

## Comparison / evaluation questions

When the question is "which should I use" or "what's best":

- Define the **criteria that matter for this user** first (performance, cost,
  ecosystem, maintenance, learning curve, license).
- Build a comparison table: options as rows, criteria as columns.
- Give a **recommendation with reasoning**, not just a neutral matrix — then note
  when a different choice would win.

Example structure:

| Option | Criterion A | Criterion B | Criterion C | Best when |
|--------|-------------|-------------|-------------|-----------|
| X      | …           | …           | …           | …         |
| Y      | …           | …           | …           | …         |

## Presenting findings

- Answer first, evidence second — never make the reader dig for the conclusion.
- Attach a source to every non-obvious claim (`file:line` or URL + title).
- Make uncertainty explicit: "confirmed", "likely", "couldn't determine".
- Size the output to the question; a large synthesis or comparison may warrant an
  Artifact for scannability.
