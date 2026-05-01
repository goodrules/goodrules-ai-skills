---
name: prd-functional
description: >
  Interview-style skill that produces the Functional Requirements section of
  PRD.md — MVP features as user stories, stretch / post-MVP, and explicit
  out-of-scope. Use when the user says "/prd-functional", "spec the
  features", "lock in the feature list", "what should the MVP do", or
  "draft user stories". Bootstraps a stub PRD.md if none exists.
---

# PRD — Functional Requirements

Produce the `## Functional Requirements` section of `PRD.md` with concrete features, user stories, and an honest out-of-scope list.

## Process

### Step 1: Read or bootstrap PRD.md

Read `PRD.md` at the project root.

- **If absent**: print "No PRD.md found. I'll bootstrap a stub and fill in the Functional Requirements section. Run `/prd` later for guided discovery on the Overview." Then write the canonical schema (see the `prd` skill's Step 4) with all sections empty and `## Overview` containing only `_To be filled — run /prd for guided discovery._`.
- **If present**: locate the `## Functional Requirements` heading. The interview will rewrite only the lines between that heading and the next `## ` line.

Read the existing `## Overview` to ground the interview in the project's stated problem and users.

### Step 2: Open-ended sweep

Ask the user, one or two questions at a time:

1. "List 3-7 things a user must be able to do on day one. Be concrete — verbs and nouns, not categories."
2. "What would tempt you to add but you should resist for v1?"
3. "What is explicitly **not** in scope, even though someone might assume it is?"

If the answers are vague ("manage their account", "see a dashboard"), re-prompt for a specific verb-and-object: "Manage how — invite teammates, change billing, delete data?"

### Step 3: Structured prompts

Use **AskUserQuestion** for these decisions:

- **MVP cut depth**: Thinnest possible (one critical flow only) / Lean + polished (3-5 flows, no rough edges) / Full v1 (everything a real user expects)
- **User auth requirement**: None (single-user local) / Email magic-link / OAuth (Google/GitHub) / SSO (enterprise) / Custom
- **Multi-tenancy model**: Single user / Per-account (one user, many workspaces) / Org-scoped (teams with shared data) / Public + private spaces

### Step 4: Write the section

Rewrite the `## Functional Requirements` section using this format:

```markdown
## Functional Requirements

### MVP features

1. **{Feature name}** — As a {user role}, I want to {capability} so that {value}.
2. **{Feature name}** — As a {user role}, I want to {capability} so that {value}.
...

### Stretch / post-MVP

- **{Feature name}** — {one-line description, deferred because: reason}
- ...

### Out of scope

- **{Thing someone might expect}** — {why it's not in v1}
- ...

### Auth & tenancy

- **Auth**: {decision from structured prompt}
- **Tenancy**: {decision from structured prompt}
```

Every MVP feature must include the `so that {value}` clause. If the user can't articulate the value, push back — that feature might belong in stretch or out-of-scope.

### Step 5: File any unresolved items

If the user said "I'm not sure" or "we'll figure that out later" on any question, append a bullet to `## Open Questions` with the `[func]` tag. Do **not** rewrite or delete existing Open Questions items.

Example:

```markdown
## Open Questions

- [func] Should imported data be editable, or read-only by design?
```

### Step 6: Update timestamp and checkpoint

- Rewrite the `_Last updated:_` line at the top of `PRD.md` to today's date.
- Print a summary to the user: count of MVP features, stretch items, out-of-scope items, and any new Open Questions.
- Ask: "Anything missing or wrong before we move on?"
