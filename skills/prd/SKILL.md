---
name: prd
description: >
  Interview-style orchestrator that produces a Product Requirements Document
  (PRD.md) at the project root for a brand-new project. Runs an open-ended
  discovery sweep, scaffolds the canonical PRD schema, then routes through
  the four domain sub-skills (prd-functional, prd-ux, prd-design,
  prd-architecture). Use when the user says "/prd", "create a PRD",
  "let's spec a new project", "start a new project", or "I have an idea".
  Owns the Overview and Open Questions sections.
---

# PRD Orchestrator

Drive an interview-style flow that turns a fuzzy product idea into a single executable `PRD.md` at the project root, then hand off to domain sub-skills for the spec sections.

## Process

### Step 1: Check for an existing PRD.md

Read `PRD.md` at the project root if it exists.

- **If it exists and looks populated**: ask the user whether to revise the existing PRD (jump to Step 5 with the existing content) or start fresh (back up the old file as `PRD.md.bak` and continue).
- **If absent or empty**: continue to Step 2.

### Step 2: Open-ended discovery

Ask the user, one or two questions at a time (not all at once), the following open-ended prompts. Wait for each answer before moving on. Do **not** use AskUserQuestion here — these are deliberately open.

1. **Problem** — "What problem does this solve, and for whom does it hurt the most today?"
2. **Target users** — "Who is the primary user? Be specific — a role, a context, an existing user of something else."
3. **Vision** — "If this works in 12 months, what is true that isn't true today? Give me a one-line pitch."
4. **Success metrics** — "How will you know it's working? Pick 1-3 measurable signals."
5. **Project name** — "What are you calling it? A working name is fine."

Reject generic answers. If the user says "users want better workflow" or "make people more productive," ask for a concrete noun: a real product they envy, a specific user, a number. Every section of the PRD requires at least one user-supplied specific.

### Step 3: Structured framing

Use **AskUserQuestion** for the three framing decisions:

- **Project type**: Web app / Mobile app / CLI tool / API service / Desktop app / Other
- **Audience scale**: Just me / Small team or community / Public consumer / Enterprise
- **Time horizon**: Weekend prototype / 2-week MVP / Quarter / Multi-quarter

### Step 4: Scaffold PRD.md

Write `PRD.md` at the project root with this exact heading structure. Populate `## Overview` from the discovery answers; leave the four owned-by-sub-skill sections as empty stubs with a `_To be filled by /prd-{name}._` placeholder. Initialize `## Open Questions` empty.

```markdown
# {Project Name} — PRD

_Last updated: {YYYY-MM-DD} — Status: Discovery_

## Overview

- **Problem**: {answer}
- **Target users**: {answer}
- **Vision**: {one-line pitch}
- **Success metrics**:
  - {metric 1}
  - {metric 2}
- **Project type**: {answer}
- **Audience scale**: {answer}
- **Time horizon**: {answer}

## Functional Requirements

_To be filled by /prd-functional._

## User Experience

_To be filled by /prd-ux._

## Design Direction

_To be filled by /prd-design._

## Architecture

_To be filled by /prd-architecture._

## Open Questions

_None yet — sub-skills will append items here as they surface._
```

### Step 5: Confirm the scaffold

Show the user the path to `PRD.md` and the contents of `## Overview`. Ask if anything should be revised before continuing.

### Step 6: Route to sub-skills

Use **AskUserQuestion** to ask how to proceed:

- **Run all four in order (recommended)** — functional → ux → design → architecture
- **Pick a subset** — orchestrator asks which to run, in what order
- **Just functional + architecture** — common MVP-only shortcut
- **Stop here, I'll invoke sub-skills manually**

If the user picks an option that runs sub-skills, invoke them in sequence by calling each sub-skill via the Skill tool (e.g., `prd-functional`, then `prd-ux`, etc.). Between sub-skills, print a one-line state summary ("Functional Requirements section locked — 5 MVP features, 3 out-of-scope items") and use **AskUserQuestion** to ask: continue / pause / jump to a different section.

### Step 7: Finalize

After the chosen sub-skills are done (or when the user stops), update the status line at the top of `PRD.md`:

- `Status: Drafting` if any owned section still has placeholder text
- `Status: Locked` if every section is populated and the user confirms

Update `_Last updated:_` to today's date.

Print a final summary:

- Sections populated vs. still-stub
- Total Open Questions count, grouped by owner tag (`[func]`, `[ux]`, `[design]`, `[arch]`)
- Suggested next step (which sub-skill to run, or "Open Questions to resolve before locking")

## Section-rewrite contract

Sub-skills follow this contract — document it here so the orchestrator and sub-skills stay in sync:

- Each sub-skill rewrites only the lines from its `## {Section}` heading up to (but not including) the next `## ` line.
- The orchestrator owns `## Overview` and `## Open Questions`. Sub-skills must **not** rewrite either.
- `## Open Questions` is **append-only**. Sub-skills add bullets tagged with their owner code (`[func]`, `[ux]`, `[design]`, `[arch]`) and never delete existing items.
- The `_Last updated:_` line is rewritten to today's date by whichever skill last edits the file.
