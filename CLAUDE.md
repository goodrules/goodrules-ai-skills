# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal collection of Claude Code **skills**. There is no application, build step, test suite, or dependency manifest — every artifact is a markdown skill definition consumed by Claude Code at runtime. "Working in this codebase" means authoring or editing skills, not compiling or running code.

## Skill anatomy

Each skill is one file: `skills/<name>/SKILL.md`. The file has two parts:

1. **YAML frontmatter** — only `name` and `description`.
   - `name` must equal the directory name.
   - `description` is the entire trigger surface. Claude decides whether to invoke a skill from this text alone, so it must pack in both the `/slash` invocation and the natural-language phrases that should fire it ("Use when the user says ... or ..."). When editing a skill's behavior, update the description's trigger phrases to match — a capability the description doesn't mention effectively doesn't exist.
2. **Markdown body** — the instructions Claude follows when the skill runs. The established shape is a `# Title`, a one-line statement of the output artifact, then a numbered `## Process` of `### Step N` sections. Skills are written as second-person instructions to the executing model, not as docs about the skill.

There is no validation tooling. When adding or editing a skill, manually verify: frontmatter present, `name` matches the directory, description carries the trigger phrases.

## The PRD skill family (the one cross-file system)

Five skills cooperate on a single `PRD.md` at the *target project's* root (not this repo):

- **`prd`** — interview-style orchestrator. Owns discovery, scaffolds the canonical `PRD.md` heading schema (defined in its Step 4), and routes to the four sub-skills.
- **`prd-functional`, `prd-ux`, `prd-design`, `prd-architecture`** — each owns exactly one `## {Section}` of `PRD.md`.

These share a **section-rewrite contract** (documented at the bottom of `skills/prd/SKILL.md`) that every change must preserve:

- A sub-skill rewrites **only** the lines from its own `## {Section}` heading up to the next `## ` line. It never touches another section.
- The orchestrator owns `## Overview` and `## Open Questions`; sub-skills must not rewrite either.
- `## Open Questions` is **append-only**. Sub-skills add bullets tagged with their owner code (`[func]`, `[ux]`, `[design]`, `[arch]`) and never delete existing items.
- The `_Last updated:_` line is rewritten to today's date by whichever skill last edits the file.
- Every sub-skill bootstraps a stub `PRD.md` (the canonical schema, Overview stubbed) if none exists, so it can run standalone.

The canonical schema lives in `skills/prd/SKILL.md` Step 4 and is referenced by all four sub-skills. If you change the heading structure, change it there and update every sub-skill that hard-codes its section name.

## Interview-skill convention

`prd*` and `project-ideation` are interview skills and follow a deliberate two-mode questioning pattern — preserve it when editing:

- **Open-ended sweep**: ask one or two questions at a time, in prose, and wait for each answer. Do **not** use `AskUserQuestion` here — these are meant to be open. Reject vague answers and re-prompt for a concrete noun/verb.
- **Structured prompts**: use `AskUserQuestion` only for discrete, enumerable decisions (project type, auth model, MVP cut depth, etc.).

Each interview skill ends by writing a named artifact to the project root (`PRD.md`, a `*-brief.md`) and printing a short summary — not by leaving the result only in chat.

## The worklog contract (`close` + `whats-next`)

Two skills share one on-disk structure at the *target project's* root (not this repo): a **`worklog/` directory**, typically gitignored.

| File | Holds |
|---|---|
| `bugs.md` | `## Open` (High/Medium/Low), `## Ruled out`, `## Recently fixed` |
| `features.md` | `## In progress`, `## Next up`, `## Backlog`, `## Shipped (recent)` |
| `ideas.md` | `## Active exploration`, `## Someday`, `## Discarded` |
| `journal.md` | `## Sessions` (last 3), `## Standing status` |

- **`close`** is the sole writer. **`whats-next`** is read-only. Changing the schema means editing both in lockstep — they previously drifted (`close` could write `MEMORY.md`, which `whats-next` had no way to find).
- **Routing is by decision test**, not vibes: bugs = "a behavior contradicts intent"; features = "I could write acceptance criteria today"; ideas = "I'd need a design conversation first". Work that is none of these (refactors, deploys, dep bumps) is *done work* and belongs in `journal.md`.
- **`## Ruled out` and `## Discarded` are append-only.** They exist to stop re-litigation, so `whats-next` must never recommend from them.
- **Bounded sections** (`## Sessions`, `## Recently fixed`, `## Shipped (recent)`) get pruned each run; git holds the history. `## Standing status` is updated in place and never pruned. These bounds are what keep the files from becoming the 992-line single file they replaced.
- **`close` never edits CLAUDE.md.** When reference-shaped material (invariants, architectural rules) accumulates in the worklog, it *flags* it for promotion and stops there — a committed file that steers every future session is not something a wrap-up skill should write to.
- **Legacy migration**: a root `WORKLOG.md`/`MEMORY.md`/`STATUS.md`/`NOTES.md` is split into the four files on `close`'s next run, behind an approval gate, with the original archived to `worklog/archive-WORKLOG.md` rather than deleted.

## Other standalone skills
- **`gitpush`** — staged-commit-then-push with a hard gate: never push without explicit `AskUserQuestion` approval; stage files by name (never `git add -A`/`.`).
- **`gemini-second-opinion`** — pure-prose skill (no helper script) that shells out to the Antigravity CLI (`agy --print`, headless) to get an independent read-only Gemini take, then has Claude synthesize it against its own analysis rather than passing it through. Documents the one quirk that matters: `agy --print` drops stdout on a non-TTY stdin, so calls always redirect `< /dev/null`.
