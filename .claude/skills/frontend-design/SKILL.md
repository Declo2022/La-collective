---
name: frontend-design
description: >-
  Design and build polished, accessible, responsive front-end UI — components,
  pages, layouts, and design systems — that look intentional in both light and
  dark themes. Use when the user asks to "design the front end", "build a UI",
  "make it look good", "create a component/landing page/dashboard", style or
  restyle an interface, or improve visual polish, spacing, and responsiveness.
---

# Frontend Design

Produce interfaces that read as one coherent system: deliberate spacing,
restrained color, real typographic hierarchy, and behavior that holds up across
screen sizes and themes. Favor clarity and consistency over decoration.

## Before writing any UI code

1. **Know the stack.** Detect the framework and styling approach already in the
   repo (React/Vue/Svelte/plain HTML; Tailwind, CSS Modules, styled-components,
   vanilla CSS) and match it. Don't introduce a new styling paradigm without
   reason.
2. **Reuse the system.** Look for existing tokens, theme files, component
   libraries, and utility classes. Extend them; never hard-code a value that a
   token already defines.
3. **Know the target.** Confirm the breakpoints, whether dark mode is required,
   and any brand palette/font. If unstated, assume responsive + both themes.

If the task is a chart, graph, dashboard, or any data visualization, use the
`dataviz` skill for color and chart specifics — this skill covers the
surrounding layout.

## Design principles

- **Spacing is a system, not a guess.** Use one consistent scale (e.g. 4/8px
  steps or the framework's spacing tokens). Whitespace is the primary tool for
  hierarchy — give elements room before adding borders or backgrounds.
- **Typography carries hierarchy.** Limit to 2–3 sizes and 2–3 weights per view.
  Establish clear heading → body → caption steps; set comfortable line-height
  (~1.5 body) and constrain measure (~60–75ch) for readability.
- **Color with restraint.** A neutral base, one accent for primary actions,
  plus semantic states (success/warning/error). Ensure text meets WCAG AA
  contrast (4.5:1 body, 3:1 large). Never rely on color alone to convey meaning.
- **Alignment and grid.** Align to a consistent grid; keep edges and baselines
  lined up. Visual order beats decoration.
- **Depth sparingly.** Prefer subtle elevation (soft shadow, hairline border) to
  heavy drop shadows and gradients. Consistent radius across components.
- **Motion with purpose.** Short (150–250ms), eased transitions on state changes;
  respect `prefers-reduced-motion`. No gratuitous animation.

## Responsive rules

- Mobile-first: base styles for small screens, layer breakpoints upward.
- Use fluid units and layout primitives (flex/grid, `min()`/`max()`/`clamp()`)
  over fixed pixel widths. `max-width: 100%` on media.
- Wide content (tables, code, diagrams) scrolls inside its own container — the
  page body never scrolls horizontally.
- Verify tap targets are ≥44px and nothing overflows at 320px width.

## Accessibility (non-negotiable)

- Semantic HTML first (`button`, `nav`, `main`, `label`), ARIA only to fill gaps.
- Every interactive element is keyboard-reachable with a visible focus state.
- Images have `alt`; form fields have associated `<label>`s.
- Don't remove focus outlines without replacing them.

## Theming (light + dark)

- Drive colors through CSS variables / theme tokens, not literals scattered in
  components, so both themes stay in sync.
- Design both themes deliberately — dark mode is not just inverted colors; check
  contrast and elevation in each.

## Workflow

1. Sketch the structure (layout regions, component tree) before styling.
2. Build with tokens and existing components; extract a reusable component when
   a pattern repeats.
3. Check the result at mobile, tablet, and desktop widths, in light and dark.
4. Run the accessibility pass (keyboard, focus, contrast, labels).
5. When possible, run the app and view the change rather than trusting the code
   (use the `run` or `verify` skill if present).

For copy-ready starting patterns (component structure, responsive layout, token
setup, a review checklist), read `references/patterns.md`.
