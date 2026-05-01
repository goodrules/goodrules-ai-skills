---
name: prd-ux
description: >
  Interview-style skill that produces the User Experience section of PRD.md —
  primary user flows, information architecture, key journeys, and edge /
  empty / error / loading states. Use when the user says "/prd-ux", "spec
  the UX", "design the user flows", "what's the IA", or "walk through the
  user journey". Bootstraps a stub PRD.md if none exists.
---

# PRD — User Experience

Produce the `## User Experience` section of `PRD.md` with concrete user flows, an information architecture sketch, and the unhappy paths that matter.

## Process

### Step 1: Read or bootstrap PRD.md

Read `PRD.md` at the project root.

- **If absent**: print "No PRD.md found. I'll bootstrap a stub and fill in the User Experience section. Run `/prd` later for guided discovery on the Overview." Then write the canonical schema (see the `prd` skill's Step 4) with all sections empty and `## Overview` containing only `_To be filled — run /prd for guided discovery._`.
- **If present**: locate the `## User Experience` heading. The interview will rewrite only the lines between that heading and the next `## ` line.

Read `## Overview` and `## Functional Requirements` (if populated) so the flows match the actual feature set.

### Step 2: Open-ended sweep

Ask the user, one or two questions at a time:

1. "Walk me through the first 60 seconds a new user spends in the product. What do they see, what do they do, what do they feel?"
2. "Pick the single most important flow after onboarding — describe it step by step."
3. "Where is failure most likely or most painful? Network down, bad input, permissions denied — what's the worst case worth designing for now?"

If the user describes a flow in vague terms ("they sign up and use it"), re-prompt for the literal screens or steps: "What's on the first screen they see after signup?"

### Step 3: Structured prompts

Use **AskUserQuestion** for these decisions:

- **Primary surface shape**: Single-page (everything in one view) / Multi-page (traditional nav) / Dashboard + detail panels / Wizard (linear steps) / Chat or conversational
- **Onboarding stance**: Zero-config (drop in and use) / Guided tour / Sample data seed / Blank slate (user starts empty)
- **Critical edge case to design for now**: Offline / slow network / Empty state / Permissions denied / Concurrent edits / None of these for v1

### Step 4: Write the section

Rewrite the `## User Experience` section using this format:

```markdown
## User Experience

### Primary surface

{Surface shape from structured prompt} — {one sentence on what that means for this product}

### Information architecture

- **{Top-level area}** → {sub-areas or key views}
- **{Top-level area}** → {sub-areas or key views}
- ...

### Key flows

1. **{Flow name}** (happy path)
   1. {Step}
   2. {Step}
   3. {Step}
2. **{Flow name}** (happy path)
   1. {Step}
   ...

### Edge cases worth designing now

- **{Edge case from structured prompt}** — {how the product behaves}
- **{Other edge case the user surfaced}** — {how the product behaves}

### Empty / error / loading states

- **Empty state for {area}**: {what the user sees and is invited to do}
- **Error state for {action}**: {what message + recovery path}
- **Loading state for {slow operation}**: {skeleton, spinner, optimistic update?}
```

Steps inside flows must reference real verbs and nouns from the Functional Requirements section. If a flow needs a feature that isn't in the functional list, surface that as a contradiction and ask the user to resolve it (add the feature, or drop the flow).

### Step 5: File any unresolved items

If the user deferred any decision, append a bullet to `## Open Questions` with the `[ux]` tag. Append-only — do not rewrite or delete existing items.

### Step 6: Update timestamp and checkpoint

- Rewrite the `_Last updated:_` line at the top of `PRD.md` to today's date.
- Print a summary: number of flows documented, edge cases covered, and any new Open Questions.
- Print the primary flow as a short text sketch (numbered steps) and ask: "Does that match what you had in mind?"
