# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> `AGENTS.md` is a symlink to this file, so Antigravity and other harnesses that look for `AGENTS.md` read the same guidance. There is one document; edit this one. Where the text names a Claude Code tool (`AskUserQuestion`) or path (`~/.claude/skills/`), read it as "the harness's equivalent".

## What this repo is

A personal collection of Claude Code **skills**. There is no application, build step, test suite, or dependency manifest: every artifact is a markdown skill definition consumed by Claude Code at runtime. "Working in this codebase" means authoring or editing skills, not compiling or running code.

## Skill anatomy

Each skill is one file: `skills/<name>/SKILL.md`. The file has two parts:

1. **YAML frontmatter**: only `name` and `description`.
   - `name` must equal the directory name.
   - `description` is the entire trigger surface. Claude decides whether to invoke a skill from this text alone, so it must pack in both the `/slash` invocation and the natural-language phrases that should fire it ("Use when the user says ... or ..."). When editing a skill's behavior, update the description's trigger phrases to match; a capability the description doesn't mention effectively doesn't exist.
2. **Markdown body**: the instructions Claude follows when the skill runs. The established shape is a `# Title`, a one-line statement of the output artifact, then a numbered `## Process` of `### Step N` sections (or equivalent clear phases). Skills are written as second-person instructions to the executing model, not as docs about the skill.

There is no validation tooling. When adding or editing a skill, manually verify: frontmatter present, `name` matches the directory, description carries the trigger phrases.

## Interview-skill convention

`project-ideation` and `grill-me` are interview skills that narrow an idea before committing to work:

- **One question at a time**: ask one sharp question, wait for the answer, and reject vague responses ("users", "better", "something with AI") by re-prompting for a concrete noun, verb, or number.
- **`project-ideation`** runs a Socratic four-phase flow (Orient, Explore, Converge, Crystallize) in open prose and saves a `<project-slug>-brief.md` with a one-page project brief and roadmap.
- **`grill-me`** keeps the interview tight (5-8 questions), uses `AskUserQuestion` with concrete options when plausible answers can be guessed, and finishes with a short commitment brief plus a first startable step.

## The worklog contract (`close` + `whats-next`)

Two skills share one on-disk structure at the *target project's* root (not this repo): a **`worklog/` directory**, typically gitignored.

| File | Holds |
|---|---|
| `bugs.md` | `## Open` (High/Medium/Low), `## Ruled out`, `## Recently fixed` |
| `features.md` | `## In progress`, `## Next up`, `## Backlog`, `## Shipped (recent)` |
| `ideas.md` | `## Active exploration`, `## Someday`, `## Discarded` |
| `journal.md` | `## Sessions` (last 3), `## Standing status` |

- **`close`** is the sole writer. **`whats-next`** is read-only. Changing the schema means editing both in lockstep; they previously drifted (`close` could write `MEMORY.md`, which `whats-next` had no way to find).
- **Routing is by decision test**, not vibes: bugs = "a behavior contradicts intent"; features = "I could write acceptance criteria today"; ideas = "I'd need a design conversation first". Work that is none of these (refactors, deploys, dep bumps) is *done work* and belongs in `journal.md`.
- **`## Ruled out` and `## Discarded` are append-only.** They exist to stop re-litigation, so `whats-next` must never recommend from them.
- **Bounded sections** (`## Sessions`, `## Recently fixed`, `## Shipped (recent)`) get pruned each run; git holds the history. `## Standing status` is updated in place and never pruned. These bounds are what keep the files from becoming the 992-line single file they replaced.
- **`close` never edits the agent instruction file** (`CLAUDE.md`, `AGENTS.md`, or the harness equivalent). When reference-shaped material (invariants, architectural rules) accumulates in the worklog, it *flags* it for promotion and stops there; a committed file that steers every future session is not something a wrap-up skill should write to.
- **Legacy migration**: a root `WORKLOG.md`/`MEMORY.md`/`STATUS.md`/`NOTES.md` is split into the four files on `close`'s next run, behind an approval gate, with the original archived to `worklog/archive-WORKLOG.md` rather than deleted.

## Other standalone skills
- **`gauntlet-loop`**: turns a goal into a short, paste-ready prompt that sets a named, fetchable, comparable quality bar and runs parallel builder and harsh critic subagents in a blind comparison loop until the output wins.
- **`gitpush`**: staged-commit-then-push with a hard gate: never push without explicit `AskUserQuestion` approval; stage files by name (never `git add -A`/`.`).
- **`gemini-second-opinion`**: pure-prose skill (no helper script) that shells out to the Antigravity CLI (`agy --print`, headless) to get an independent read-only Gemini take, then has Claude synthesize it against its own analysis rather than passing it through. Two things keep it from rotting: it passes **model slugs** (`gemini-3.8-flash-high`), not display names, and it tells the model to run `agy models` for the live list rather than trusting the table in the skill. A `< /dev/null` redirect was previously mandatory on every call to work around dropped stdout on non-TTY stdin; that no longer reproduces, so it survives only as a one-line retry hint.
- **`find-skills`**: discovers and installs skills from the open agent skills ecosystem via `npx skills` (`skills.sh`).
