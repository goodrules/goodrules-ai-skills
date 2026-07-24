---
name: whats-next
description: Read the project's worklog — the `worklog/` directory (`bugs.md`, `features.md`, `ideas.md`, `journal.md`), or a legacy single-file `WORKLOG.md`/`MEMORY.md`/`STATUS.md`/`NOTES.md` — and recommend the next priority work: fixes, enhancements, follow-ups, deferred items. Use whenever the user asks "what's next", "what should I work on", "next priorities", "where do I pick up", "what's left", "what bugs are open", or types `/whats-next`. Also surface proactively after a `/close` or session-wrap when the user seems to be planning the next session. Pulls from the worklog rather than guessing — if no worklog exists, says so plainly instead of fabricating.
---

# whats-next

Read the project worklog and recommend what to work on next. The goal is a short, opinionated list — not a full backlog dump.

## How this works

The user maintains a worklog that captures session-by-session state. Since the split, that's a **`worklog/` directory**:

```
worklog/
  bugs.md       open defects + Ruled out
  features.md   scoped capability work
  ideas.md      unscoped direction
  journal.md    last 3 sessions + standing status
```

Your job is to read those files, understand the current state, and surface the **3–5 highest-priority items** with reasoning — not regurgitate the whole backlog.

The user already wrote down what's left. They want help deciding **which of those things to do next**, accounting for impact, blockers, and what was just shipped.

You are **read-only** across all four files. `/close` owns them; never write.

## Step 1: Locate the worklog

Try in this order:

1. **`worklog/` at the project root** — the current structure. Read all four files.
2. `docs/worklog/`, `notes/worklog/`, `.claude/worklog/`
3. **Legacy single-file worklog** at the project root: `WORKLOG.md`, `MEMORY.md`, `STATUS.md`, `NOTES.md` — all four are names `/close` has historically written. Also check `docs/WORKLOG.md`, `notes/WORKLOG.md`, `.claude/WORKLOG.md`.
4. Glob fallback near the root: `*WORKLOG*`, `*worklog*`, `SESSION*.md`, `CHANGELOG.md` (`find . -maxdepth 3 -iname "*worklog*"` or similar)

**Ignore `worklog/archive-*`** — those are pre-migration snapshots kept for safety, not live state.

If a legacy single file is found and there's **no** `worklog/`, read it anyway and give the recommendation, then mention that `/close` will split it into the four-file structure on its next run. Don't refuse to help over a stale format.

If nothing exists, **stop and say so**. Don't invent priorities from `git log` or scattered TODOs — the user asked for worklog-based suggestions specifically. Offer to help start one (e.g., via `/close`) if that fits.

If multiple candidate locations exist, prefer `worklog/` over any legacy file; otherwise prefer the most recently modified and tell the user which you're reading.

## Step 2: Parse

### From `worklog/` (current structure)

- **`bugs.md`** — `## Open` (grouped `### High` / `### Medium` / `### Low`) is a candidate pool. `## Recently fixed` is off the table. `## Ruled out` is **off-limits** (see below).
- **`features.md`** — `## In progress` and `## Next up` are the main candidate pool. `## Backlog` is a weaker pool — pull from it only when the top two are thin. `## Shipped (recent)` is off the table.
- **`ideas.md`** — generally **not** a candidate pool. Ideas are unscoped by definition, so "do this next" doesn't apply. Surface an idea only when the actionable backlog is thin, or when the user explicitly asks about direction rather than tasks. `## Discarded` is **off-limits**.
- **`journal.md`** — `## Sessions` gives the `**Last session shipped:**` line and recency signal for follow-ups. `## Standing status` gives current posture; use it to spot-check whether a backlog item is already handled.

**Never recommend anything listed in `bugs.md` `## Ruled out` or `ideas.md` `## Discarded`.** Those sections exist specifically to stop work from being re-litigated. If you believe a ruled-out item deserves reopening, say so explicitly as a flag under "Worth a sanity check" — don't slip it into the recommendations.

### From a legacy single file

Worklogs vary in style, but most have these sections (under various names):

- **Completed** — "What Was Accomplished", "Done", "Shipped". Off the table.
- **Remaining / Next** — "Remaining Items", "Next Priorities", "Backlog", "TODO", "Open". The candidate pool.
- **Blocked / Deferred** — note the blocker; only recommend if it has lifted.
- **False alarms / verified-not-a-bug** — treat exactly like `## Ruled out`: off-limits.

Read the full file. Don't skim. Pay attention to:

- Items the user explicitly flagged as "next biggest win" or similar — those carry weight.
- Dependencies between items ("validate #2 first to see if it's still needed").
- Time-boxes ("defer to July 2026") — respect them; don't recommend deferred items as "next" unless the window has passed.
- Effort/impact hints ("~5-line change", "multi-day refactor", "bigger lift").

## Step 3: Rank candidates

Apply this prioritization, in roughly this order:

1. **Open `### High` bugs.** Something is broken. These outrank feature work by default — override only when the bug is genuinely low-impact or the user has signalled otherwise.
2. **Unblocked items the user already flagged as top priority.** If a file's ordering or an explicit "next biggest win" note says so, that's a strong signal — don't override it without reason.
3. **Verification/validation work that gates other items.** If item A is "verify X feels right; if not, do B", recommend A before B.
4. **`## In progress` features.** Half-finished work has the highest carrying cost; finishing beats starting.
5. **Small wins with clear scope** when bigger items are blocked or risky. A "~5-line change" that ships value beats a "multi-day refactor" that doesn't fit the session.
6. **Items that compound** — fixes that unblock other work, or infrastructure that enables future items.
7. **Recently-shipped follow-ups** — if the last session shipped something, surface its known follow-ups before pivoting to unrelated areas.

Deprioritize:

- Anything in `## Ruled out` or `## Discarded` — excluded entirely, not merely deprioritized.
- Anything explicitly time-boxed to a future date.
- Anything blocked on external dependencies (email service, third-party approval, etc.) — note them but don't recommend.
- Unscoped ideas, unless the actionable backlog is thin.

## Step 4: Write the recommendation

Output 3–5 items, ranked. For each, include:

- **What**: one-sentence description (your words, not a copy-paste).
- **Why now**: the reasoning — what makes this rank where it does. Reference the signals you found (e.g., "only open High bug", "gates #3 below", "last session left this half-done").
- **Effort/risk shape**: rough sizing if the worklog gives signal — "small, ~5 lines" vs. "session-sized, needs rollback paths". Don't fabricate estimates the worklog doesn't support.
- **Blockers/dependencies**: anything that needs to happen first, or should be checked before starting.

Then a short closing section:

- **Deferred / blocked** — one line each for items intentionally not recommended, with the reason. Keeps the user from worrying you missed them.
- **Worth a sanity check** — anything that seems stale, inconsistent, or might already be done. Don't fix it; just flag it.

## Output format

```markdown
## What's next — based on `worklog/`

**Last session shipped:** <one-line summary from journal.md's most recent session>

### Recommended next

1. **<Short title>** — <what>
   - Why now: <reasoning>
   - Shape: <effort/risk>
   - Watch: <blockers, dependencies, or pre-flight checks>

2. ...

### Deferred or blocked (not recommended)
- <item> — <reason>

### Worth a sanity check
- <item> — <why it might be stale or already done>
```

**Cite by file, not by number.** Item numbering is per-file now, so "item #1" is ambiguous — write `bugs.md → "Refresh-token reuse window"` or `features.md ## Next up → "Optimistic mutation updates"`.

## Style notes

- **Be opinionated.** The user wants a recommendation, not a menu. If the backlog has 12 open items and you list all 12, you've failed — pick 3–5 and say why.
- **Don't invent context.** If the worklog doesn't say why something matters, don't make up a justification. It's fine to say "user listed but didn't elaborate; ask before starting".
- **Push back if the top items look wrong.** If the highest-priority item is clearly stale or contradicted by recent commits, say so. The worklog is the user's plan from a past session — current state may have changed. (Use `git log --oneline -20` to spot-check if something feels off.)
- **Keep it tight.** This is a triage tool, not a planning doc. Aim for a response that fits on one screen.

## Edge cases

- **Empty or near-empty worklog**: Say the backlog has no actionable items yet. Suggest running `/close` after the next session, or ask if they want you to look at recent commits / open TODOs instead (separate decision — don't auto-pivot).
- **`worklog/` exists but is partially populated**: normal. `/close` bootstraps stubs. Just note which files are empty and work from what's there.
- **Only ideas, no bugs or features**: the backlog is all unscoped. Say so, and recommend *scoping* one idea as the next action rather than pretending it's ready to build.
- **Legacy file and `worklog/` both present**: prefer `worklog/`; mention the stray legacy file so the user can delete it. (Post-migration it should be at `worklog/archive-WORKLOG.md`, not the root.)
- **Worklog is from a much older session**: if the most recent date is weeks/months stale, flag it — recommendations might be obsolete. Suggest a quick `git log` review before acting.
