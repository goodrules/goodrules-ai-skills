---
name: prd-design
description: >
  Interview-style skill that produces the Design Direction section of PRD.md —
  aesthetic stance, reference products, color system, typography, density,
  and motion. Use when the user says "/prd-design", "spec the design",
  "design direction", "what should it look like", or "lock in the visual
  style". Bootstraps a stub PRD.md if none exists.
---

# PRD — Design Direction

Produce the `## Design Direction` section of `PRD.md` with concrete aesthetic intent that a designer or AI could turn into a real interface.

## Process

### Step 1: Read or bootstrap PRD.md

Read `PRD.md` at the project root.

- **If absent**: print "No PRD.md found. I'll bootstrap a stub and fill in the Design Direction section. Run `/prd` later for guided discovery on the Overview." Then write the canonical schema (see the `prd` skill's Step 4) with all sections empty and `## Overview` containing only `_To be filled — run /prd for guided discovery._`.
- **If present**: locate the `## Design Direction` heading. The interview will rewrite only the lines between that heading and the next `## ` line.

Read `## Overview` and `## User Experience` (if populated) so the visual direction matches the audience and surface shape.

### Step 2: Open-ended sweep

Ask the user, one or two questions at a time:

1. "Name 2-3 real products whose look you'd be proud to be confused with. Be specific — Linear, Notion, Stripe Dashboard, Apple Music, etc."
2. "What feeling should the very first screen create? One adjective is fine — calm, energetic, serious, playful, premium."
3. "Anything you specifically want to avoid? A look you've seen done badly?"

If the user says "modern" or "clean" or "professional," push for a concrete reference — every interface is supposedly modern and clean. The reference products are the load-bearing answer; without them the section will read as slop.

### Step 3: Structured prompts

Use **AskUserQuestion** for these decisions:

- **Aesthetic axis**: Minimal (Linear, Stripe) / Editorial (Medium, NYT) / Playful (Duolingo, Notion) / Brutalist (raw, deliberate) / Corporate (enterprise SaaS)
- **Color mode**: Light only / Dark only / Both (light default) / Both (dark default) / System (follow OS)
- **Typography stance**: System fonts only / One display face + system body / Full custom pair (display + body)
- **Density**: Airy (generous whitespace) / Balanced / Dense (information-rich)

### Step 4: Write the section

Rewrite the `## Design Direction` section using this format:

```markdown
## Design Direction

### Aesthetic

- **Stance**: {axis from structured prompt}
- **Reference products**: {2-3 named products}
- **Feeling on first screen**: {adjective}
- **Avoid**: {anti-references, if any}

### Color system

- **Mode**: {light / dark / both / system}
- **Palette intent**: {1-2 sentences on neutral baseline + accent strategy — e.g., "Near-white background, near-black text, single saturated accent for primary actions"}

### Typography

- **Stance**: {system / display+body / custom pair}
- **Display intent**: {what role the display face plays — headlines, brand moments, none}
- **Body intent**: {readability priority — long-form prose, dense data, UI labels}

### Density & motion

- **Density**: {airy / balanced / dense} — {one sentence on what that means here}
- **Motion stance**: {none / subtle (200ms transitions) / expressive (animated state changes)} — {one sentence on where motion is used}
```

Do **not** invent specific hex values, font names, or pixel sizes. The PRD captures intent; the design system doc (or a `/design-consultation`-style skill) is where concrete values live.

### Step 5: File any unresolved items

If the user deferred any decision, append a bullet to `## Open Questions` with the `[design]` tag. Append-only — do not rewrite or delete existing items.

### Step 6: Update timestamp and checkpoint

- Rewrite the `_Last updated:_` line at the top of `PRD.md` to today's date.
- Print a 4-line summary: aesthetic stance, color mode, typography stance, density.
- Ask: "Lock this direction, or revise?"
