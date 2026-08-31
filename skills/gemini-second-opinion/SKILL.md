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

Get an independent take from a headless Gemini agent (`agy`, the Antigravity
CLI) and **synthesize** it against your own analysis. You own the reasoning and
the final answer; `agy` supplies one more perspective. Present one coherent
review with confidence signals — never a raw passthrough.

## When to use

- **A second analytical perspective adds confidence** — code reviews, security
  audits, architecture decisions, debugging hypotheses.
- **You're cross-checking your own work** before presenting it.
- **The user asks** — "ask Gemini", "get a second opinion", "what would another
  model say".

Skip it for pure logic with no external dependency, simple facts you can answer
confidently, or when latency matters more than thoroughness.

## The invocation

`agy --print` runs a single prompt non-interactively and writes the response to
stdout. Without `--dangerously-skip-permissions` it can't approve tool calls, so
it stays effectively read-only — it reads what you give it and reasons.

```bash
agy --model gemini-3.7-flash-high -p "Act as a senior security engineer. Review this for auth bugs:

$(cat src/auth.py)"
```

- `-p` / `--print` / `--prompt` takes the **prompt as its value** — keep it last.
- stdout is the response text and nothing else; diagnostics go to stderr. Check
  the exit code — non-zero means failure (auth, timeout), so read stderr to see why.
- `--print-timeout` already defaults to 5m. Only pass it for a genuinely long job.
- If a call ever returns empty stdout, retry with `< /dev/null` appended — some
  builds drop output when stdin is an open pipe.

### Model selection

Pass the **slug**, not the display name — slugs are stable and shell-safe. Run
`agy models` for the live list; it changes, so don't trust this table when a
model name errors.

| Tier | `--model` slug | Use for |
|---|---|---|
| Flash (default) | `gemini-3.7-flash-high` | most reviews |
| Flash-lo | `gemini-3.7-flash-low` | trivial / cheap checks |
| Pro | `gemini-3.1-pro-high` | deep architecture, hard reasoning |

The `-high` / `-medium` / `-low` suffix *is* the reasoning effort — there's no
separate flag to set alongside it.

### Prompting

Print mode has no system-instructions flag, so **prime the role in the prompt
itself** — lead with "Act as a …", matched to the task: senior software engineer
(code review), senior security engineer (audit), principal engineer
(architecture), QA engineer (test generation), senior engineer doing root cause
analysis (debugging), technical editor (prose).

Embed the content directly and **bound it** — one file or one diff beats a whole
tree:

```bash
# Review a diff
agy --model gemini-3.7-flash-high -p "Act as a senior reviewer. Find bugs in this diff:

$(git diff HEAD~1)"

# Bound large inputs — never embed an unbounded file
agy --model gemini-3.7-flash-high -p "Act as a senior engineer doing root cause analysis. Diagnose these errors:

$(tail -n 200 error.log)"
```

For a question spanning many files, point `agy` at the repo with `--add-dir
<path>` so it reads files itself instead of you pasting them. Anything needing a
real tool (web search) also needs `--dangerously-skip-permissions`, since print
mode can't show approval prompts — that grants write access too, so leave it off
for plain read-and-reason second opinions.

## Prerequisites

`agy models` should list Gemini models. An auth/sign-in error means the user
needs to run `agy` once interactively to sign in; "command not found" means the
Antigravity CLI isn't installed.

## Synthesis pattern

The value is comparing perspectives, not relaying a second output:

1. **Form your own analysis first** — don't anchor on `agy`'s output.
2. **Call `agy`** with a focused, role-primed prompt.
3. **Compare:**
   - **Both agree** → high confidence, present as solid findings.
   - **You only** → medium confidence, give your rationale.
   - **`agy` only** → investigate before presenting; don't relay it unverified.
   - **Contradiction** → flag it for the user, with both sides.

`agy` is a second opinion, not ground truth. Present one synthesized review, not
two separate dumps.
