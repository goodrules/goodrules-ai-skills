---
name: local-review
description: Get an independent second-opinion review from a local model (Gemma 4 via Ollama) — read-only critique of a diff, file, plan, or UI screenshot, at zero API cost and fully on-device. Use this skill whenever you want an outside check before committing, whenever you catch yourself about to trust your own reasoning without a sanity check, whenever the user asks to "review", "critique", "get a second opinion", "sanity-check", or "poke holes in" a change, plan, or design, and whenever the user wants feedback kept local or wants to avoid spending API tokens on review. Also use it for quick UI/UX critique of a screenshot, since the local model is multimodal. Prefer this over reviewing entirely in your own head when independence matters.
---

# local-review — Gemma 4 second opinion

An independent reviewer running locally through Ollama. Its whole value is that it did **not** write the code or the plan under review, so it breaks the echo chamber where you rate your own work highly. It is read-only: it never edits files, it only returns critique.

## When to reach for it

- Before a commit — pipe the staged diff for a bug/edge-case/security pass.
- When you're about to act on your own plan or reasoning and want an outside gut-check.
- Reviewing a specific file for problems.
- Quick UI/UX or accessibility critique of a screenshot (Gemma 4 is multimodal).

## Prerequisites

- The local server must be up. If a call fails with a connection error, tell the user to run `ollama serve` in their shell, then retry.
- Requires `gemma4:26b` pulled and `jq` installed.

## How to use it

The script reads content from `--file`, `--image`, or stdin, plus an optional `--focus` describing what to look for.

```bash
# Review the staged diff for specific concerns
git diff --cached | scripts/review.sh --focus "concurrency and error handling"

# Review a single file
scripts/review.sh --file src/portfolio.py

# Second opinion on your own plan (pipe your plan text in)
echo "$MY_PLAN" | scripts/review.sh --focus "flaws, missing steps, wrong assumptions"

# UI critique of a screenshot
scripts/review.sh --image path/to/dashboard.png --focus "UX, hierarchy, accessibility"
```

## How to treat the output

The feedback is **advisory, not authoritative**. Gemma is a small local model — it will sometimes miss things or raise non-issues. Read its critique, keep what's real, discard what isn't, and stay the decision-maker yourself. Never blindly apply its suggestions. When you surface its feedback to the user, attribute it ("the local reviewer flagged…") and add your own judgment on which points actually matter.

## Session note

Gemma and Qwen (see `local-forge`) can't both stay resident on a 48GB Mac at large context — requesting one evicts the other, and each swap is a slow cold reload. If you'll do both review and generation in a session, **batch all the reviews together** rather than ping-ponging between the two models.
