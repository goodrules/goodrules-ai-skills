---
name: close
description: >
  End-of-session skill that summarizes work accomplished and updates the
  project's worklog — a `worklog/` directory holding `bugs.md`, `features.md`,
  `ideas.md`, and `journal.md`. Routes each finding to the right file, removes
  stale items, prunes old sessions, and generates next steps. Use this skill
  whenever the user says "/close", "close the session", "wrap up", "end
  session", "session update", or "update the session file". Also use when the
  user asks to summarize what was done today, capture progress before ending
  work, log a bug or feature idea for later, or migrate an old single-file
  WORKLOG.md into the split structure.
---

# Close Session

Wrap up the current working session by producing an accurate, current worklog at the project root.

## The worklog is a directory, not a file

```
worklog/
  bugs.md       open defects + Ruled out
  features.md   scoped capability work
  ideas.md      unscoped direction
  journal.md    last 3 sessions + standing status
```

It's typically gitignored — a developer-local running journal, not part of the shipped repo. Don't add it to git unless the project's existing convention does.

This skill is the **sole writer** of all four files. `whats-next` only reads them.

Older projects have a single `WORKLOG.md` (or `MEMORY.md`, `STATUS.md`, `NOTES.md`) at the root. Step 1 migrates those.

### Routing rules

Every backlog item goes in exactly one file. Each has a decision test — apply it literally rather than going on vibes:

- **`bugs.md`** — something exists and doesn't behave as intended: defect, regression, security gap, broken config. *Test: is there a behavior that contradicts intent?*
- **`features.md`** — a scoped capability change. *Test: could I write acceptance criteria today?*
- **`ideas.md`** — direction or capability not yet scoped. *Test: would I need a design conversation before I could start?*

**Tiebreaker for the bug/feature line**, which is where most misfiling happens: if the mechanism **exists but doesn't cover a path**, it's a bug — a guarantee is broken. If the mechanism **doesn't exist at all**, it's a feature. ("A suppression list exists but the transactional send path never consults it" is a bug. "There's no way to un-suppress an address" is a feature.) Go by what an item *describes*, not what it's *titled* — items are often named like features but describe broken behavior.

**Neither?** Refactors, dependency bumps, deploys, and doc work are *done work* — they go in `journal.md`, not a backlog file. They only enter a backlog file if work remains, and then they're usually features.

**Graduation:** ideas → features once scoped. `ideas.md` is the incubator; moving an item out of it is normal and good.

### Section rules

- `## Ruled out` (bugs) and `## Discarded` (ideas) are **append-only**. Never delete an entry — preventing re-litigation is their entire purpose.
- `## Recently fixed` and `## Shipped (recent)` keep roughly the last 2 sessions' worth. `## Sessions` keeps the last 3. Git holds the rest.
- `## Standing status` is updated **in place** and never pruned.
- `_Last updated:_` is rewritten to today's date in every file you touch.
- Any missing file is bootstrapped as a stub, so each file can be updated standalone.

## Process

### Step 1: Locate or migrate

Check, in order:

1. **`worklog/` exists** → use it. Skip to Step 2.
2. **A legacy root worklog exists** (`WORKLOG.md`, `MEMORY.md`, `STATUS.md`, or `NOTES.md`) → run the migration below, then continue to Step 2.
3. **Neither** → scaffold `worklog/` with the four stubs from Step 4 and continue. Do not enter migration mode.

#### Migration (once per project, gated on approval)

Read the legacy file **completely** — don't skim; items buried mid-file are exactly the ones that get dropped. Then:

1. Classify every backlog item into bugs / features / ideas using the routing rules.
2. Route the non-backlog content: "false alarms" / "verified — not a bug" / "do NOT re-investigate" → `bugs.md` `## Ruled out`; status tables and posture snapshots → `journal.md` `## Standing status`; dated session narratives (`## Session Update — <date>`) → `journal.md` `## Sessions`, keeping the 3 most recent.
3. Identify **reference-shaped** material — invariants, architecture maps, domain models, deployment topology. **List these for CLAUDE.md promotion. Do not move them and do not edit CLAUDE.md.** See Step 5.
4. **Show the proposed split and ask before writing anything.** Report per-file item counts and the reference material you're flagging. A legacy worklog is usually gitignored, so a bad split has no git undo — this approval gate is not optional.
5. On approval, write `worklog/`, then move the legacy file to `worklog/archive-WORKLOG.md`. Don't delete it (no git safety net) and don't leave it at the root (`whats-next` would find it as a competing candidate).
6. **`.gitignore`:** if the legacy file was gitignored, add `worklog/` — skipping this leaks a previously-private file into git. Leave the now-stale legacy line alone and tell the user what you changed.

**Nothing may be silently dropped.** Every item lands in a file, gets flagged for CLAUDE.md, or is explicitly called out as discarded. Count items before and after and reconcile the two numbers; if they don't match, say so rather than guessing.

When counting, **don't assume list markers are well-formed.** Hand-maintained worklogs accumulate odd ones — `15b.`, `16b.`, `2.1`, `*` — and a naive scan for `- ` and `N. ` walks straight past them. (A real 992-line worklog hid two substantial items behind `15b.`/`16b.` markers this way.) Match permissively — `^[-*+] `, `^[0-9]+[a-z]?[.)] `, `^[0-9]+\.[0-9]+ ` — and eyeball the tail of each section for stragglers.

### Step 2: Read the existing files

Read all four. Understand what's open, what was already ruled out or discarded, and what the last session did.

### Step 3: Reconstruct the session

Review the conversation for everything accomplished, then **ground it in the repo** — conversation history is lossy, especially in a long or compacted session. Run in parallel:

- `git log --oneline` back to the last journal entry's date
- `git status --short` and `git diff --stat` for uncommitted work

Look for features added or modified, bugs fixed, configuration and deployment changes, refactors and renames, security fixes, infrastructure changes — and investigations that concluded "not actually broken", which are `## Ruled out` entries and the easiest thing here to lose.

For each item, note the specific files changed and the technical details — precise enough that someone reading cold understands exactly what changed and why.

If the session produced no durable change (pure exploration, questions answered), say so and update only `journal.md`. Don't manufacture backlog items to justify the run.

### Step 4: Route, reconcile, and write

Apply the routing rules to every finding, then reconcile each file against what happened: **remove** items completed this session or any prior one, **keep** what's still open, **add** what this session surfaced, **re-prioritize** if the session changed what matters. Prune the bounded sections. Write only the files that actually changed.

Before adding anything, check it isn't already in `## Ruled out` or `## Discarded`. If the session *reversed* one of those calls, move the entry out and note why — don't leave it in both places.

**`worklog/bugs.md`**

```markdown
# Bugs

_Last updated: YYYY-MM-DD_

## Open

### High
- **{Title}** — {symptom}. `{file:line}`. {Fix direction if known.}

### Medium

### Low

## Ruled out
- ❌ **{Claim}** — {why it isn't a bug}. Verified {date}.

## Recently fixed
- **{Title}** — {what changed}. Fixed {date}.
```

**`worklog/features.md`**

```markdown
# Features

_Last updated: YYYY-MM-DD_

## In progress
- **{Title}** — {what's built, what's left}. `{files}`.

## Next up
- **{Title}** — {scope and acceptance criteria}.

## Backlog
- **{Title}** — {one line}.

## Shipped (recent)
- **{Title}** — {what landed}. Shipped {date}.
```

**`worklog/ideas.md`**

```markdown
# Ideas

_Last updated: YYYY-MM-DD_

## Active exploration
- **{Title}** — {the idea, and what would need deciding to scope it}.

## Someday
- **{Title}** — {one line}.

## Discarded
- **{Title}** — {why dropped}. {date}
```

**`worklog/journal.md`**

```markdown
# Journal

_Last updated: YYYY-MM-DD_

## Sessions

### YYYY-MM-DD — {session title}
- {what happened, with file paths}
→ bugs.md: 2 fixed, 1 new · features.md: 1 shipped

_(last 3 sessions; older pruned — see git log)_

## Standing status
{snapshots updated in place, never pruned — security posture, env status}
```

Writing guidelines:

- Bold the item name, em-dash, then the description
- Include file paths, env var names, and technical details that matter
- Keep entries scannable — if a backlog item needs three paragraphs, it's a feature that wants a spec, not a bullet
- The journal's `→` line is the audit trail tying a session to the files it changed
- If a session entry for today already exists, extend it in place rather than adding a second one for the same date
- Preserve `## Standing status` content, updating it to reflect current state; drop rows no longer accurate

### Step 5: Flag CLAUDE.md promotion candidates

If reference-shaped material has accumulated in the worklog — invariants, architectural rules, domain constraints — list it and suggest promoting it to CLAUDE.md.

**Do not edit CLAUDE.md.** It's a committed file that steers every future session; an automated wrap-up is too blunt an instrument for it. Flag and let the user decide.

The signal to look for: content written as a *rule* ("Do NOT make a request path await an email send") rather than as *status* ("auth is currently ✅"). Rules belong in CLAUDE.md, where they're auto-loaded and can actually fire. Status belongs in the worklog. Pure lookup detail that's recoverable from config files is usually best deleted rather than relocated.

Don't re-flag material you already flagged in a previous session and the user left in place.

### Step 6: Refresh the knowledge graph (only if `graphify-out/` exists)

If a `graphify-out/` directory exists at the project root, the project maintains a graphify knowledge graph — refresh it in incremental update mode (`/graphify --update`), honoring any project-specific graphify flags in the project's CLAUDE.md. If the update fails, note it in the summary and continue; a failed graph refresh must not block closing the session.

If `graphify-out/` does not exist, skip this step entirely — don't build a graph, don't mention it.

### Step 7: Confirm with the user

Give a brief summary:

- Per file: items added, items removed as completed, items pruned
- Anything moved between files (an idea that graduated, a bug that was ruled out)
- Whether migration ran, and where the legacy file was archived
- Any CLAUDE.md promotion candidates flagged
- Whether the knowledge graph was refreshed (only if Step 6 ran)
