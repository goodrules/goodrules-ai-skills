---
name: whats-next
description: Read the project's worklog — the `worklog/` directory (`bugs.md`, `features.md`, `ideas.md`, `journal.md`), or a legacy single-file `WORKLOG.md`/`MEMORY.md`/`STATUS.md`/`NOTES.md` — and recommend the next priority work: fixes, enhancements, follow-ups, deferred items. Use whenever the user asks "what's next", "what should I work on", "next priorities", "where do I pick up", "what's left", "what bugs are open", or types `/whats-next`. Also surface proactively after a `/close` or session-wrap when the user seems to be planning the next session. Pulls from the worklog rather than guessing — if no worklog exists, says so plainly instead of fabricating.
---

# whats-next

Read the project worklog and recommend what to work on next. The goal is a short, opinionated list — not a full backlog dump.

The user already wrote down what's left. They want help deciding **which of those things to do next**, accounting for impact, blockers, and what was just shipped. Surface the **3–5 highest-priority items** with reasoning.

You are **read-only** across every worklog file. `/close` owns them; never write.

## Step 1: Locate the worklog

Try in this order:

1. **`worklog/` at the project root** — the current structure (`bugs.md`, `features.md`, `ideas.md`, `journal.md`). Read all four.
2. `docs/worklog/`, `notes/worklog/`, `.claude/worklog/`
3. **Legacy single file** — `WORKLOG.md`, `MEMORY.md`, `STATUS.md`, or `NOTES.md`, at the root or under `docs/`, `notes/`, `.claude/`. All four are names `/close` has historically written.

**Ignore `worklog/archive-*`** — those are pre-migration snapshots kept for safety, not live state.

If multiple candidates exist, prefer `worklog/`; otherwise take the most recently modified and say which you're reading.

If only a legacy single file exists, read it and give the recommendation anyway, then mention that `/close` will split it into the four-file structure on its next run. Don't refuse to help over a stale format.

If nothing exists, **stop and say so.** Don't invent priorities from `git log` or scattered TODOs — the user asked for worklog-based suggestions specifically. Offer to start one via `/close`.

## Step 2: Parse

**Candidate pools**, strongest first:

- **`bugs.md` `## Open`** — grouped `### High` / `### Medium` / `### Low`.
- **`features.md` `## In progress` and `## Next up`** — the main feature pool. `## Backlog` is weaker; pull from it only when the top two are thin.
- **`ideas.md`** — generally *not* a candidate pool. Ideas are unscoped by definition, so "do this next" doesn't apply. Surface one only when the actionable backlog is thin, or when the user asks about direction rather than tasks.

**Off the table:** `## Recently fixed`, `## Shipped (recent)` — already done.

**Off-limits entirely:** `bugs.md` `## Ruled out` and `ideas.md` `## Discarded`. Those sections exist specifically to stop work from being re-litigated. If you believe a ruled-out item deserves reopening, say so under "Worth a sanity check" — never slip it into the recommendations.

**Context, not candidates:** `journal.md` `## Sessions` — the most recent `### YYYY-MM-DD — {title}` entry and its `→` line tell you what last shipped and which files changed; summarize that yourself for the header line. `## Standing status` gives current posture — use it to spot-check whether a backlog item is already handled.

In a **legacy single file** the section names vary but the mapping holds: "What Was Accomplished" / "Done" / "Shipped" are off the table; "Remaining" / "Next Priorities" / "Backlog" / "TODO" / "Open" are the pool; "false alarms" / "verified — not a bug" are off-limits like `## Ruled out`.

Read the full file either way, and pay attention to:

- Items the user explicitly flagged as "next biggest win" — those carry weight.
- Dependencies ("validate #2 first to see if it's still needed").
- Time-boxes ("defer to July 2026") — respect them.
- Effort/impact hints ("~5-line change", "multi-day refactor").

## Step 3: Rank

1. **Open `### High` bugs.** Something is broken; these outrank feature work by default. Override only when the bug is genuinely low-impact or the user signalled otherwise.
2. **Items the user already flagged as top priority**, or that gate other items ("verify X; if not, do B" → recommend the verification first).
3. **`## In progress` features.** Half-finished work has the highest carrying cost; finishing beats starting.
4. **Small, clearly-scoped wins** when the bigger items are blocked or risky — and **follow-ups to what last shipped** before pivoting to an unrelated area.

Don't recommend: anything ruled out or discarded (excluded, not merely deprioritized), anything time-boxed to a future date, anything blocked on an external dependency (note it, don't recommend it), or unscoped ideas unless the backlog is thin.

## Step 4: Write the recommendation

```markdown
## What's next — based on `worklog/`

**Last session shipped:** <one-line summary you derive from journal.md's most recent session entry>

### Recommended next

1. **<Short title>** — <what, in your words, not a copy-paste>
   - Why now: <the signals that put it here — "only open High bug", "gates #3", "left half-done last session">
   - Shape: <effort/risk, only if the worklog gives signal>
   - Watch: <blockers, dependencies, pre-flight checks>

2. ...

### Deferred or blocked (not recommended)
- <item> — <reason>

### Worth a sanity check
- <item> — <why it might be stale or already done>
```

**Cite by file, not by number.** Numbering is per-file, so "item #1" is ambiguous — write `bugs.md → "Refresh-token reuse window"` or `features.md ## Next up → "Optimistic mutation updates"`.

## Style notes

- **Be opinionated.** If the backlog has 12 open items and you list all 12, you've failed. Pick 3–5 and say why.
- **Don't invent context.** If the worklog doesn't say why something matters, say "user listed but didn't elaborate; ask before starting".
- **Push back if the top items look wrong.** The worklog is a plan from a past session; current state may have moved. If something looks stale or contradicted by recent commits, say so — `git log --oneline -20` is a cheap spot-check.
- **Keep it tight.** This is a triage tool, not a planning doc. Aim for one screen.

## Edge cases

- **Empty or near-empty worklog** — say the backlog has no actionable items yet. Offer to look at recent commits or open TODOs instead, but don't auto-pivot.
- **Partially populated `worklog/`** — normal; `/close` bootstraps stubs. Note which files are empty and work from the rest.
- **Only ideas, no bugs or features** — say the backlog is all unscoped, and recommend *scoping* one idea as the next action rather than pretending it's ready to build.
- **Legacy file and `worklog/` both present** — prefer `worklog/`; mention the stray file so the user can delete it. Post-migration it belongs at `worklog/archive-WORKLOG.md`, not the root.
- **Worklog weeks or months stale** — flag it; recommendations may be obsolete. Suggest a quick `git log` review first.
