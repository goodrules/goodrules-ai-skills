# goodrules-ai-skills

A personal collection of [Claude Code](https://claude.com/claude-code) **skills**. Each skill is a single `skills/<name>/SKILL.md`: YAML frontmatter (`name` + `description`) plus a markdown body of instructions the agent follows when the skill runs. There's no build step or dependency manifest; the artifacts are the skills themselves.

## Installing a skill

Claude Code loads skills from `~/.claude/skills/`. Copy or symlink the ones you want:

```bash
ln -s "$PWD/skills/close" ~/.claude/skills/close
```

Then invoke by slash command (e.g. `/close`) or let the agent trigger it from the skill's `description`.

## Skills

| Skill | What it does |
|-------|--------------|
| `close` | End-of-session wrap-up. Writes a `worklog/` directory (`bugs.md`, `features.md`, `ideas.md`, `journal.md`), routing each finding to the right file and pruning stale entries. Migrates a legacy single-file `WORKLOG.md` on first run. |
| `whats-next` | Reads the `worklog/` and recommends the 3-5 highest-priority next items, with reasoning. Read-only counterpart to `close`. |
| `project-ideation` | Socratic brainstorming that ends in a one-page project brief and rough roadmap. |
| `grill-me` | Interactive idea narrowing: ask sharp questions, refuse vague answers, and produce a short commitment brief plus first concrete step. |
| `gauntlet-loop` | Turns any goal into a short, paste-ready "gauntlet loop" prompt that sets a concrete quality bar and loops a builder and harsh critic until the output beats the reference blind. |
| `gitpush` | Staged-commit-then-push with an explicit approval gate. |
| `gemini-second-opinion` | Independent read-only take from a Gemini agent via the Antigravity CLI (`agy`). |
| `find-skills` | Discover and install skills from the open agent skills ecosystem via `npx skills`. |

