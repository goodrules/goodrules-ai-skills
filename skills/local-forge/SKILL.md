---
name: local-forge
description: Offload high-volume, low-stakes code generation and large-context codebase questions to a local model (Qwen3-Coder 30B via Ollama) — free, on-device, and using its 256K context. Use this skill whenever the work is repetitive generation you'd rather not spend API tokens on: writing unit tests, drafting docstrings/comments, generating boilerplate, or drafting commit messages. Also use it for "where in the codebase…" / "which files do X" questions across many files at once, since its large context can hold a lot of source. Reach for it whenever the user wants to save tokens, keep code local/private, or work offline, or says "generate tests", "draft docstrings", "write a commit message", "scaffold", or asks a broad question over a pile of files. The local model GENERATES; you review and apply — never let it drive multi-file edits autonomously.
---

# local-forge — Qwen3-Coder local workhorse

Qwen3-Coder is the agentic-coding-tuned local model, but the right way to use it here is **as a generator, not an autonomous agent**. Local models lose the thread on multi-file, multi-step work, so the pattern is always: Qwen produces a candidate, **you (Claude) review it and apply it**. That keeps you as orchestrator while pushing the cheap, bulky, or private work off the API.

## Good jobs for it

- **Tests** — scaffold unit tests for a file. High volume, easy for you to vet.
- **Docstrings/comments** — annotate a file without changing logic.
- **Commit messages** — draft from the staged diff.
- **Codebase Q&A** — feed many files via stdin and ask a question; exploits the 256K context.
- **Boilerplate / raw prompts** — anything repetitive and low-stakes.

## Bad jobs for it

Complex reasoning, security-critical logic, subtle multi-file refactors, architecture decisions. Keep those on Claude. If a task needs real judgment, don't route it here.

## Prerequisites

- The local server must be up. If a call fails with a connection error, tell the user to run `ollama serve`, then retry.
- Requires `qwen3-coder:30b` pulled and `jq` installed.

## How to use it

```bash
# Generate unit tests for a file
scripts/forge.sh tests src/portfolio.py

# Draft docstrings for a file (outputs the full annotated file)
scripts/forge.sh docs src/ingest.py

# Draft a commit message from staged changes
scripts/forge.sh commit

# Codebase question over many files (pipe context in)
cat src/*.py | scripts/forge.sh ask "Where do we open DB sessions, and are any left unclosed?"

# Arbitrary prompt, optional piped context
scripts/forge.sh raw "Convert this to Pydantic v2 style" < model.py
```

## How to treat the output

Always **review before applying**. Qwen's output is a draft: check tests actually exercise the right behavior, docstrings are accurate, the commit message matches the diff. Apply it yourself (write the file, stage the commit) rather than trusting it blind — you own correctness, it owns throughput.

## Session note

Qwen and Gemma (see `local-review`) can't both stay resident on a 48GB Mac at large context — requesting one evicts the other, and each swap is a slow cold reload. If a session needs both generation and review, **batch all the Qwen work together**, then switch to review, rather than alternating.
