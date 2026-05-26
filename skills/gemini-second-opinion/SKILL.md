---
name: gemini-second-opinion
description: >
  Uses Gemini CLI in headless mode to get an independent "second opinion" from
  a different foundation model. Use when you want a second perspective on code
  reviews, test generation, architecture decisions, security audits, debugging,
  prose editing, brainstorming, or any task where cross-model validation adds
  confidence. Trigger on phrases like "get a second opinion", "ask Gemini",
  "cross-check this", "what would another model say", or when a subagent or
  skill workflow calls for external model validation. Also use proactively when
  reviewing your own output — an independent reviewer beats self-grading.
---

# Second Opinion via Gemini CLI

Use Gemini CLI as an independent analysis and review tool. Claude handles
reasoning and orchestration. Gemini provides a second perspective. The final
response is a considered synthesis, not a raw passthrough.

## When to use

Invoke Gemini when:

- **A second analytical perspective adds confidence**
  Code reviews, security audits, architecture decisions, debugging hypotheses

- **Research or current information is needed**
  Latest versions, recent changes, current best practices, unfamiliar libraries
  Keywords: "latest", "current", "newest", "recent", "2025", "2026"

- **Cross-checking your own work**
  Before presenting a review, plan, or analysis — get Gemini's independent take
  and note where you agree (high confidence) and diverge (needs human eyes)

- **The user explicitly asks**
  "Ask Gemini", "get a second opinion", "what would Gemini say"

Do NOT invoke Gemini for:

- Pure reasoning or logic tasks with no external dependency
- Code already fully in context that doesn't need a second reviewer
- Simple factual questions you can answer confidently
- Tasks where latency matters more than thoroughness

## Prerequisites

Gemini CLI must be installed and authenticated. The `jq` utility is required
for JSON parsing. Before executing any Gemini call, verify `jq` is available:

```bash
command -v jq >/dev/null || { echo "jq is required but not installed" >&2; exit 1; }
```

If `jq` is missing, advise the user to install it (`brew install jq`,
`apt install jq`, etc.) before proceeding.

## Basic usage

Always use JSON output for reliable parsing:

```bash
# Direct prompt
result=$(gemini -p "Your prompt here" --output-format json)
echo "$result" | jq -r '.response'

# File inclusion with @ syntax
result=$(gemini -p "@src/auth.ts Review this for security issues" --output-format json)
echo "$result" | jq -r '.response'

# Multiple files
result=$(gemini -p "@src/ @tests/ Analyze test coverage gaps" --output-format json)
echo "$result" | jq -r '.response'

# Pipe content + prompt
cat src/auth.py | gemini -p "Review for security issues" --output-format json | jq -r '.response'

# Git diff review
git diff HEAD~1 | gemini -p "Review these changes for bugs" --output-format json | jq -r '.response'
```

## Role priming

Because Gemini is invoked statelessly with no project context, prepend a role
to every prompt so it knows the lens to apply. Claude has the broader context —
use it to prime Gemini appropriately.

```bash
# Instead of this:
gemini -p "@src/auth.ts Review for bugs" --output-format json

# Do this:
gemini -p "Act as a senior security engineer. Review @src/auth.ts for authentication bugs, session fixation, and token handling issues" --output-format json
```

Match the role to the task:

| Task | Role prefix |
|---|---|
| Code review | "Act as a senior software engineer performing a code review." |
| Security audit | "Act as a senior security engineer." |
| Architecture | "Act as a principal engineer evaluating system design." |
| Test generation | "Act as a QA engineer writing comprehensive test cases." |
| Debugging | "Act as a senior engineer performing root cause analysis." |
| Prose / docs | "Act as a technical editor reviewing documentation." |

## Model selection

Pick the model based on the task:

| Task type | Model | Why |
|---|---|---|
| Web search, current info | `gemini-3-flash-preview` | Fast, search-oriented |
| Deep code analysis, architecture | `gemini-3.1-pro-preview` | Strongest reasoning |
| Quick lookups, simple questions | `gemini-3.1-flash-lite` | Lowest latency, cheapest |
| Complex multi-file review | `gemini-3.1-pro-preview` | Larger effective context |
| Lightweight review, docs | `gemini-3-flash-preview` | Good balance of speed and quality |

```bash
# Specify model with -m
gemini -p "query" -m gemini-3-flash-preview --output-format json
```

When in doubt, use `gemini-3.1-pro-preview` — it's the safe default for
anything requiring judgment. Verify model strings match what `gemini --help`
reports, as available models change over time.

## Output handling

Gemini headless with `--output-format json` returns:

```json
{
  "response": "The actual answer text",
  "stats": { ... },
  "error": { "type": "...", "message": "..." }
}
```

Always check the exit code first, then parse JSON. If the CLI fails entirely
(network timeout, auth error, crash), it may return non-JSON and `jq` will
throw a parse error.

```bash
result=$(gemini -p "prompt" --output-format json 2>/dev/null)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
  echo "Gemini CLI failed (exit code $exit_code)" >&2
else
  error=$(echo "$result" | jq -r '.error.message // empty' 2>/dev/null)
  if [[ -n "$error" ]]; then
    echo "Gemini error: $error" >&2
  else
    echo "$result" | jq -r '.response'
  fi
fi
```

## Scope discipline

Keep input focused. Don't send entire repos when a single file will do.

```bash
# Good — targeted
gemini -p "@src/auth.ts Review the token refresh logic" --output-format json

# Good — specific directory
gemini -p "@src/middleware/ Check for missing error handling" --output-format json

# Avoid — too broad unless explicitly needed
gemini -p "@. Review everything" --all-files --output-format json
```

Use `--include-directories` only when the question genuinely needs cross-cutting
context (e.g., architecture reviews spanning multiple modules).

For log files and large inputs, always truncate to a reasonable window. Never
pipe unbounded streams into Gemini:

```bash
# Good — bounded
tail -n 200 error.log | gemini -p "Identify root cause of these errors" --output-format json

# Bad — could be gigabytes
cat error.log | gemini -p "Identify root cause" --output-format json
```

## Defensive quoting

When constructing prompts programmatically, watch for quote and variable
interpolation issues. For complex or multi-line prompts, prefer the `@file`
syntax or heredocs over inline `-p` strings:

```bash
# Simple prompt — inline is fine
gemini -p "Review @src/auth.ts for security issues" --output-format json

# Complex prompt — use a temp file to avoid quoting hell
cat <<'PROMPT' > /tmp/gemini-prompt.txt
Act as a senior security engineer. Review the following code for:
1. SQL injection via user-supplied parameters
2. Session fixation in the token refresh flow
3. Missing rate limiting on auth endpoints
PROMPT
gemini -p "$(cat /tmp/gemini-prompt.txt) @src/auth.ts" --output-format json
```

## Common task patterns

### Code review

```bash
gemini -p "Act as a senior software engineer. Review @src/auth.ts for bugs, security issues, and maintainability" \
  -m gemini-3.1-pro-preview --output-format json | jq -r '.response'
```

### Test generation

```bash
gemini -p "Act as a QA engineer. Generate comprehensive unit tests with edge cases for @src/utils.py" \
  -m gemini-3.1-pro-preview --output-format json | jq -r '.response'
```

### Security audit

```bash
gemini -p "Act as a senior security engineer. Audit @src/api/ for injection, auth flaws, and data exposure" \
  -m gemini-3.1-pro-preview --output-format json | jq -r '.response'
```

### Architecture review

```bash
gemini -p "Act as a principal engineer. Evaluate @src/ for separation of concerns, coupling, and scalability" \
  -m gemini-3.1-pro-preview --output-format json | jq -r '.response'
```

### Debug assistance

```bash
# Pipe recent error logs + source — always bound the log input
tail -n 200 error.log | gemini -p "Act as a senior engineer. @src/worker.ts Identify root cause of these errors" \
  --output-format json | jq -r '.response'
```

### Prose / docs review

```bash
gemini -p "Act as a technical editor. Review @docs/README.md for clarity, completeness, and accuracy" \
  -m gemini-3-flash-preview --output-format json | jq -r '.response'
```

### Web research

```bash
gemini -p "What are the breaking changes in Next.js 15?" \
  -m gemini-3-flash-preview --output-format json | jq -r '.response'
```

## Synthesis pattern

The real value is in comparing perspectives, not just getting a second output.
When using Gemini as a second opinion, follow this workflow:

1. **Form your own analysis first** — don't anchor on Gemini's output
2. **Call Gemini** with a focused, specific, role-primed prompt
3. **Compare and synthesize:**
   - **Consensus** — both agree → high confidence, present as solid findings
   - **Claude only** — you found it, Gemini didn't → medium confidence, present with rationale
   - **Gemini only** — Gemini found it, you missed it → investigate before presenting
   - **Contradiction** — direct disagreement → flag for the user with both perspectives

Present the synthesis to the user, not the raw Gemini output. The user gets
a single coherent review with confidence signals, not two separate dumps.

## Integration examples

### Slash command (`.claude/commands/review-with-gemini.md`)

```markdown
Review the file at $ARGUMENTS with a Gemini second opinion.

1. Read the file and write your own review.
2. Run: gemini -p "Act as a senior software engineer. Review @$ARGUMENTS for bugs, security issues, and code quality" -m gemini-3.1-pro-preview --output-format json
3. Extract the response with jq.
4. Present a synthesized review noting consensus and divergence.
```

### Subagent instruction snippet

```
To get Gemini's perspective, run:
  gemini -p "Act as a {relevant role}. @{file_path} {your analysis prompt}" -m gemini-3.1-pro-preview --output-format json
Parse with: echo "$result" | jq -r '.response'
Compare findings with your own analysis before presenting results.
```

### From another skill

```markdown
## External review step
After generating your output, get a second opinion:
  result=$(gemini -p "Act as a {relevant role}. @{output_file} Review for quality and correctness" --output-format json)
Incorporate useful feedback. Note disagreements with rationale.
```

## Key principles

- Gemini is a **complement**, not a replacement — Claude owns the final synthesis
- Always use `--output-format json` for automation
- Check exit code first, then `.error`, then `.response`
- Prime every prompt with a role that matches the task
- Keep `@` scopes focused — better signal in, better signal out
- Truncate large inputs — use `tail`, `head`, or line limits, never unbounded `cat`
- Use heredocs or temp files for complex prompts to avoid quoting issues
- Don't treat Gemini's output as ground truth — it's a second opinion
- Mind latency (3-15s typical) — parallelize batch operations when possible
