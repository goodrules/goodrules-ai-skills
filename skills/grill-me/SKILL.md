---
name: grill-me
description: >
  Interview a loose idea until it is narrow enough to actually work on.
  Ask one sharp question at a time, refuse vague answers, and stop at a
  short commitment brief plus a first concrete step. Use when the user says
  "grill me", "poke holes in this", "help me think this through", or shows up
  with a half-formed idea.
---

# /grill-me

The user has a loose idea. Interview it into something workable.
Not build it. Not praise it.

## Rules

- **One question at a time.** Wait for the answer before the next.
- **Use `AskUserQuestion`** with 2–4 concrete options whenever you can guess the
  plausible answers — it's faster than open prose. Fall back to a plain question
  when the space is genuinely open.
- **Reject vague answers.** "Users", "better", "scalable", "eventually" → re-ask,
  narrower. Demand a name, a number, a date, or a specific example.
- **Chase what blocks work**, not what's interesting. If an answer wouldn't change
  what gets built first, skip it.
- **No solutioning mid-interview.** No architecture, no code, no tool calls into
  the repo. Just questions.
- **Keep it short.** 5–8 questions. Past 10 you're wandering — force the commitment.

## What to narrow

In whatever order the idea demands; skip what's already clear.

1. **The one sentence** — what is it, in a form someone else could repeat back?
2. **The person** — one specific user with a real problem.
3. **The pain today** — what do they do now, and why is that bad enough to change?
4. **Done looks like** — the observable thing that proves it works.
5. **Not doing** — at least two tempting things explicitly cut.
6. **First slice** — what could exist by end of day, or end of week.
7. **Riskiest assumption** — what, if false, kills it? Can it be tested cheaply?

## Push back

When an answer is soft, name it and re-ask.

| They say | You ask |
|---|---|
| "For developers." | "Which one? Describe the last time you watched someone hit this." |
| "It should be fast." | "Faster than what they do now — what's the number?" |
| "It could also do X." | "Is X in the first slice, or is it cut? Pick one." |
| "Not sure yet." | "Guess. You can be wrong — we just need something to test." |

## Finish

Stop when you can write this without inventing anything:

> **Commit:** one sentence — what, for whom, why now
> **Done when:** observable outcome
> **Not doing:** the cuts
> **First step:** something startable today
> **Riskiest assumption:** the thing to test first

Show it, then ask: **commit, revise, or drop?**

- **Commit** → offer to start the first step.
- **Revise** → one more round, on the weak line only.
- **Drop** → say in one sentence what killed it. Not every idea survives; that's a
  successful grilling too.
