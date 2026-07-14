# Frontend Design Patterns

Copy-ready starting points. Adapt to the repo's actual stack — these show the
shape, not a mandate to introduce a new tool.

## Design tokens (CSS variables, theme-aware)

```css
:root {
  /* spacing scale (8px base) */
  --space-1: 0.25rem;  --space-2: 0.5rem;  --space-3: 0.75rem;
  --space-4: 1rem;     --space-6: 1.5rem;  --space-8: 2rem;   --space-12: 3rem;

  /* radius + elevation */
  --radius: 0.5rem;
  --shadow-sm: 0 1px 2px rgba(0,0,0,.06);
  --shadow-md: 0 4px 12px rgba(0,0,0,.10);

  /* type scale */
  --text-sm: .875rem; --text-base: 1rem; --text-lg: 1.25rem; --text-xl: 1.75rem;

  /* light theme colors */
  --bg: #ffffff;        --surface: #f7f7f8;   --border: #e5e5e8;
  --text: #1a1a1e;      --text-muted: #6b6b72;
  --accent: #4f46e5;    --accent-contrast: #ffffff;
  --success: #15803d;   --warning: #b45309;   --danger: #b91c1c;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg: #0f0f12;      --surface: #1a1a1f;   --border: #2b2b31;
    --text: #f2f2f4;    --text-muted: #a1a1aa;
    --accent: #818cf8;  --accent-contrast: #0f0f12;
  }
}
/* explicit toggle wins in both directions */
:root[data-theme="dark"]  { color-scheme: dark; }
:root[data-theme="light"] { color-scheme: light; }
```

## Accessible button component (React example)

```tsx
type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "secondary";
};

export function Button({ variant = "primary", ...props }: ButtonProps) {
  return <button className={`btn btn--${variant}`} {...props} />;
}
```

```css
.btn {
  display: inline-flex; align-items: center; gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius); font: inherit; font-weight: 600;
  min-height: 44px; cursor: pointer;
  transition: background-color 180ms ease, transform 180ms ease;
}
.btn:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
.btn--primary   { background: var(--accent); color: var(--accent-contrast); border: none; }
.btn--secondary { background: transparent; color: var(--text); border: 1px solid var(--border); }
@media (prefers-reduced-motion: reduce) { .btn { transition: none; } }
```

## Responsive layout primitives

```css
/* auto-fitting card grid — no manual breakpoints needed */
.grid {
  display: grid;
  gap: var(--space-6);
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr));
}

/* fluid heading size */
.h1 { font-size: clamp(var(--text-xl), 4vw + 1rem, 2.5rem); line-height: 1.2; }

/* readable prose column */
.prose { max-width: 70ch; line-height: 1.6; }

/* wide content scrolls in its own box, page never does */
.scroll-x { max-width: 100%; overflow-x: auto; }
```

## Card component structure

```html
<article class="card">
  <header class="card__header">
    <h3 class="card__title">Title</h3>
    <p class="card__meta">Supporting metadata</p>
  </header>
  <div class="card__body"><!-- content --></div>
  <footer class="card__actions"><!-- buttons --></footer>
</article>
```

```css
.card {
  background: var(--surface); border: 1px solid var(--border);
  border-radius: var(--radius); padding: var(--space-6);
  box-shadow: var(--shadow-sm);
  display: flex; flex-direction: column; gap: var(--space-4);
}
```

## Review checklist

- [ ] Spacing uses the scale/tokens — no stray magic numbers.
- [ ] ≤3 font sizes and ≤3 weights in the view; clear hierarchy.
- [ ] Body text ≥4.5:1 contrast in light AND dark; large text ≥3:1.
- [ ] Works at 320px, tablet, and desktop; no horizontal body scroll.
- [ ] Every interactive element keyboard-reachable with a visible focus ring.
- [ ] Images have alt; inputs have labels; semantic elements used.
- [ ] Colors come from tokens; both themes checked deliberately.
- [ ] Motion is subtle and respects `prefers-reduced-motion`.
