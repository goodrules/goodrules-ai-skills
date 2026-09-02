# goodrules-ai-skills

A personal collection of [Claude Code](https://claude.com/claude-code) **skills**. Each skill is a single `skills/<name>/SKILL.md` — YAML frontmatter (`name` + `description`) plus a markdown body of instructions Claude follows when the skill runs. Some skills ship a `scripts/` helper alongside the SKILL.md. There's no build step or dependency manifest; the artifacts are the skills themselves.

## Installing a skill

Claude Code loads skills from `~/.claude/skills/`. Copy or symlink the ones you want:

```bash
ln -s "$PWD/skills/local-review" ~/.claude/skills/local-review
```

Then invoke by slash command (e.g. `/local-review`) or let Claude trigger it from the skill's `description`.

## Skills

| Skill | What it does |
|-------|--------------|
| `local-forge` | Offload high-volume, low-stakes generation (tests, docstrings, commit messages, codebase Q&A) to a **local** Qwen3-Coder model via Ollama. Qwen generates; Claude reviews and applies. |
| `local-review` | Independent second-opinion review of a diff, file, plan, or UI screenshot from a **local** Gemma 4 model via Ollama. Read-only critique, zero API cost. |
| `prd` + `prd-*` | Interview-style PRD authoring: an orchestrator plus four domain sub-skills that each own one section of a `PRD.md`. |
| `project-ideation` | Socratic brainstorming that ends in a one-page project brief and rough roadmap. |
| `close` | End-of-session wrap-up. Writes a `worklog/` directory (`bugs.md`, `features.md`, `ideas.md`, `journal.md`), routing each finding to the right file and pruning stale entries. Migrates a legacy single-file `WORKLOG.md` on first run. |
| `whats-next` | Reads the `worklog/` and recommends the 3–5 highest-priority next items, with reasoning. Read-only counterpart to `close`. |
| `gitpush` | Staged-commit-then-push with an explicit approval gate. |
| `gemini-second-opinion` | Independent read-only take from a Gemini agent via the Antigravity CLI. |
| `grill-me` | Interactive idea narrowing: ask sharp questions, refuse vague answers, and produce a short commitment brief plus first concrete step. |
| `find-skills` | Discover and install skills from the open agent skills ecosystem via `npx skills`. |

## Serving the local models with Ollama

`local-forge` and `local-review` are the two example skills that call a **local** model instead of the API. They talk to [Ollama](https://ollama.com)'s OpenAI-compatible endpoint at `http://localhost:11434/v1/chat/completions`. Set it up once:

**1. Install Ollama** — <https://ollama.com/download> (macOS/Linux/Windows), or on macOS:

```bash
brew install ollama
```

**2. Pull the two models** the skills use:

```bash
ollama pull qwen3-coder:30b   # ~18 GB — used by local-forge
ollama pull gemma4:26b        # ~17 GB — used by local-review (multimodal)
```

**3. Start the server** (leave it running; default port `11434`):

```bash
ollama serve
```

The macOS/Windows desktop app serves automatically when open, so `ollama serve` is only needed for a headless/CLI setup.

**4. Install `jq`** — both helper scripts parse JSON responses with it:

```bash
brew install jq
```

Verify everything is live:

```bash
ollama ps                                   # what's currently resident
curl -s http://localhost:11434/v1/models | jq -r '.data[].id'
```

### Notes

- **Server down?** Both skills tell Claude to run `ollama serve` if a call fails with a connection error, then retry.
- **One model at a time.** On a 48 GB Mac these two large-context models don't stay resident together — requesting one evicts the other, and each swap is a slow cold reload. Batch all `local-forge` work, then all `local-review` work, rather than alternating.
- **The local model drafts; Claude decides.** `local-forge` output is a candidate Claude reviews before applying; `local-review` feedback is advisory. Neither skill lets the local model edit files.
