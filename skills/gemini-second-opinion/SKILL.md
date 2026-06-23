---
name: gemini-second-opinion
description: >
  Gets an independent "second opinion" from a Gemini agent via the Antigravity
  CLI (`agy`) in headless print mode. Use when you want a second perspective on
  code reviews, test generation, architecture decisions, security audits,
  debugging, prose editing, brainstorming, or any task where cross-model
  validation adds confidence. Trigger on phrases like "get a second opinion",
  "ask Gemini", "cross-check this", "what would another model say", or when a
  subagent or skill workflow calls for external model validation. Also use
  proactively when reviewing your own output — an independent reviewer beats
  self-grading. Every call sends content to an external service, so invoke only
  when the user asks or a workflow step explicitly calls for it.
---

# Second Opinion via the Antigravity CLI

Get an independent take from a headless Gemini agent (the Antigravity CLI,
`agy`) and **synthesize** it against your own analysis. Claude owns reasoning,
orchestration, and the final answer; `agy` supplies a second perspective. You
present one coherent review with confidence signals — never a raw passthrough.

`agy --print` runs a single prompt non-interactively and writes the response to
stdout. With no `--dangerously-skip-permissions` flag it can't write files or
run commands, so it stays effectively read-only — it reads what you give it and
reasons.

## When to use

Invoke a second opinion when:

- **A second analytical perspective adds confidence** — code reviews, security
  audits, architecture decisions, debugging hypotheses.
- **You're cross-checking your own work** — get an independent take before
  presenting, then note agreement (high confidence) and divergence (needs eyes).
- **The user explicitly asks** — "ask Gemini", "get a second opinion", "what
  would another model say".

Do NOT invoke for: pure logic tasks with no external dependency, code already
fully in context that needs no second reviewer, simple facts you can answer
confidently, or when latency matters more than thoroughness.

## Prerequisites

- **`agy` installed and authenticated.** `agy models` should list Gemini models;
  if it errors with an auth/sign-in message, the user needs to run `agy` once
  interactively to sign in. If `agy` isn't on PATH, the Antigravity CLI isn't
  installed.

## The invocation

One command. Always redirect `< /dev/null` — in print mode `agy` drops stdout
when stdin is a non-TTY (which it always is under a tool call), so without it the
call hangs and returns nothing.

```bash
agy --model "Gemini 3.5 Flash (High)" --print-timeout 5m \
  -p "Act as a senior security engineer. Review this for auth bugs:

$(cat src/auth.py)" < /dev/null
```

- `-p` / `--print` / `--prompt` takes the **prompt as its value** — keep it last.
- stdout is the response text, nothing else. Diagnostics go to stderr; check the
  exit code (non-zero = failure, e.g. auth or timeout — read stderr to see why).

### Model selection

`agy` names models by exact string (run `agy models` to see the live list). Pick
by task weight:

| Tier | Exact `--model` name | Use for |
|---|---|---|
| Flash (default) | `Gemini 3.5 Flash (High)` | most reviews, the default |
| Flash-lo | `Gemini 3.5 Flash (Low)` | trivial / cheap checks |
| Pro | `Gemini 3.1 Pro (High)` | deep architecture / hard reasoning |

### Role priming

Print mode has no separate system-instructions flag, so **prime the role in the
prompt itself** — lead with "Act as a …". Claude has the broader context; set the
lens to match the task:

| Task | Role prefix |
|---|---|
| Code review | "Act as a senior software engineer performing a code review." |
| Security audit | "Act as a senior security engineer." |
| Architecture | "Act as a principal engineer evaluating system design." |
| Test generation | "Act as a QA engineer writing comprehensive test cases." |
| Debugging | "Act as a senior engineer performing root cause analysis." |
| Prose / docs | "Act as a technical editor reviewing documentation." |

### Providing context

Embed the relevant content directly in the prompt (`$(cat file)`, a pasted diff,
bounded log tail). Keep it focused — a single file or diff beats a whole tree.

```bash
# Review a diff
git diff HEAD~1 | { agy --model "Gemini 3.5 Flash (High)" --print-timeout 5m \
  -p "Act as a senior reviewer. Find bugs in this diff:

$(cat)" < /dev/null; }

# Bound large inputs — never embed an unbounded file
agy --model "Gemini 3.5 Flash (High)" --print-timeout 5m \
  -p "Act as a senior engineer doing root cause analysis. Diagnose these errors:

$(tail -n 200 error.log)" < /dev/null
```

For a question spanning many files, point `agy` at the repo with `--add-dir
<path>` so it reads files itself instead of you pasting them. Web/search tools
need `--dangerously-skip-permissions` (print mode can't show approval prompts) —
only add it when the task genuinely needs a tool, since it also grants write
access; for plain read-and-reason second opinions, leave it off.

## Synthesis pattern

The value is comparing perspectives, not relaying a second output:

1. **Form your own analysis first** — don't anchor on `agy`'s output.
2. **Call `agy`** with a focused, role-primed prompt.
3. **Compare and synthesize:**
   - **Consensus** — both agree → high confidence, present as solid findings.
   - **Claude only** — you found it, it didn't → medium confidence, with rationale.
   - **Agent only** — it found it, you missed it → investigate before presenting.
   - **Contradiction** — direct disagreement → flag for the user, both sides.

Present the synthesis — one coherent review with confidence signals — not two
separate dumps. Don't treat `agy`'s output as ground truth; it's a second
opinion.
