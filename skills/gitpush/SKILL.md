---
name: gitpush
description: >
  Stage, commit, and push changes to git. Reviews the diff, generates a commit message,
  stages files, commits, and asks for explicit user approval before pushing. Use when
  the user says "/gitpush", "push this", "commit and push", or "ship it".
---

# Git Push

Review changes, commit, and push to remote — with user approval before the push.

## Process

### Step 1: Review current state

Run these commands in parallel to understand what's changed:

- `git status` — see untracked and modified files
- `git diff` and `git diff --cached` — see unstaged and staged changes
- `git log --oneline -5` — recent commits for message style reference
- `git branch --show-current` — confirm which branch we're on

### Step 2: Draft a commit message

Analyze the diff to write a clear, concise commit message:

- Summarize the **why**, not just the what
- Match the style of recent commits in the repo
- Keep the first line under 72 characters
- Add a body if the change is non-trivial
- Do NOT add any co-author trailers or agent attributions — authorship belongs solely to the user

### Step 3: Stage and commit

- Stage relevant files by name — do NOT use `git add -A` or `git add .`
- Skip files that look like secrets (`.env`, credentials, tokens)
- Create the commit using a HEREDOC for the message

### Step 4: Ask for approval before pushing

Use AskUserQuestion to show the user:

- The branch name
- The commit message
- A summary of files changed
- Ask: "Push to remote?"

**Do NOT push without explicit approval.** Wait for the user to confirm.

### Step 5: Push

Only after the user approves:

- Run `git push -u origin <branch>` (use `-u` to set upstream if needed)
- Report the result — confirm success or surface any errors

## Notes

- Never use `--no-verify`. If a pre-commit hook fails, fix the underlying issue and create a **new** commit. Do not `--amend` a failed-hook commit — that commit did not happen.
- Never force-push unless the user explicitly asks for it.
