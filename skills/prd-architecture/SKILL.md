---
name: prd-architecture
description: >
  Interview-style skill that produces the Architecture section of PRD.md —
  stack (frontend / backend / runtime), data model sketch, integrations,
  deployment target, and non-functional requirements. Use when the user
  says "/prd-architecture", "spec the stack", "what should we build it
  with", "data model", "lock in the tech stack", or "deployment plan".
  Bootstraps a stub PRD.md if none exists.
---

# PRD — Architecture

Produce the `## Architecture` section of `PRD.md` with concrete stack choices, a data model sketch, and the non-functional requirements that will actually constrain implementation.

## Process

### Step 1: Read or bootstrap PRD.md

Read `PRD.md` at the project root.

- **If absent**: print "No PRD.md found. I'll bootstrap a stub and fill in the Architecture section. Run `/prd` later for guided discovery on the Overview." Then write the canonical schema (see the `prd` skill's Step 4) with all sections empty and `## Overview` containing only `_To be filled — run /prd for guided discovery._`.
- **If present**: locate the `## Architecture` heading. The interview will rewrite only the lines between that heading and the next `## ` line.

Read `## Overview`, `## Functional Requirements`, and `## User Experience` (if populated) so the stack matches the actual product — don't suggest Postgres for a single-user CLI, don't suggest SQLite for a multi-tenant SaaS.

### Step 2: Open-ended sweep

Ask the user, one or two questions at a time:

1. "Any stack you must use, or must avoid? Existing skills, hosting accounts, team standards, hard nopes?"
2. "What scale are you actually expecting in month one? Be honest — 10 users, 1,000, 100,000?"
3. "What entities does the system need to remember? List the nouns — user, project, document, message, etc."

If the user says "scalable" or "enterprise-grade" without numbers, push for a real expected request rate, data volume, or user count. Architecture decisions hinge on actual constraints, not adjectives.

### Step 3: Structured prompts

Use **AskUserQuestion** for these decisions. Skip a prompt if the open-ended sweep already answered it definitively.

- **Frontend**: Next.js / Vite + React / SvelteKit / Astro / None (backend-only) / Other
- **Backend**: Same as frontend (BFF) / Separate Node service / Python (FastAPI / Django) / Go / Serverless functions / Other
- **Data store**: Postgres / SQLite / Firestore / DynamoDB / Redis-only / None yet
- **Auth provider**: Clerk / Auth0 / Supabase Auth / NextAuth / Roll-own / None (matches Functional decision)
- **Deploy target**: Vercel / Fly.io / Cloud Run / Render / Self-host (Docker) / Undecided
- **Hard non-functional requirements** (multi-select): Latency-sensitive (<200ms p95) / Offline-capable / SOC2 / GDPR / HIPAA / High availability (99.9%+) / None of these for v1

### Step 4: Write the section

Rewrite the `## Architecture` section using this format:

```markdown
## Architecture

### Stack

| Layer | Choice | Why |
|---|---|---|
| Frontend | {choice} | {one-line reason — fits team, fits surface, etc.} |
| Backend | {choice} | {one-line reason} |
| Data store | {choice} | {one-line reason} |
| Auth | {choice} | {one-line reason} |
| Deploy | {choice} | {one-line reason} |

### Data model sketch

Entities and relationships (sketch-level, not a schema):

- **{Entity}** — {short description}. Owns: {fields that matter}. Relates to: {other entity, by relationship type}.
- **{Entity}** — {short description}. Owns: {fields}. Relates to: {entity, relationship}.

### Integrations

- **{Service}** — {what it does for us, e.g., "Stripe — payments and subscription billing"}
- ...
- _None for v1_ (if applicable)

### Deployment

- **Target**: {choice}
- **Environments**: {dev only / dev + prod / dev + staging + prod}
- **CI/CD**: {GitHub Actions / platform built-in / manual for v1}

### Non-functional requirements

- **Expected scale (month one)**: {users / requests / data volume from open-ended sweep}
- **Latency budget**: {p95 target if specified, else "not a hard constraint for v1"}
- **Compliance / security**: {selected NFRs, or "standard hygiene only — no formal compliance"}
- **Availability**: {target if specified}
```

Don't invent infrastructure the user didn't ask for — no Kubernetes, no message queues, no microservices unless the user surfaced a real need.

### Step 5: File any unresolved items

If the user said "undecided" or surfaced a question they can't answer yet, append a bullet to `## Open Questions` with the `[arch]` tag. Append-only — do not rewrite or delete existing items.

Common arch open-questions worth surfacing explicitly:

- Background job processing (do we need a queue?)
- File / blob storage (S3-compatible? local for v1?)
- Search (database LIKE? dedicated index later?)
- Observability (logs only for v1, or structured tracing from day one?)

### Step 6: Update timestamp and checkpoint

- Rewrite the `_Last updated:_` line at the top of `PRD.md` to today's date.
- Print a one-line stack summary: "Stack: {frontend} + {backend} + {data store} on {deploy target}, auth via {auth}."
- Print the count of entities, integrations, and any new Open Questions.
- Ask: "Lock the architecture, or are there unknowns to file as Open Questions before we move on?"
