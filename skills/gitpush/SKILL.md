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
- `git status -sb` — current branch plus its upstream and ahead/behind counts

If there is nothing to commit and nothing unpushed, say so and stop — don't create an empty commit.

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
- If the tree holds unrelated work-in-progress, stage only what belongs to this change and tell the user what you left behind
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

- Run `git push -u origin <branch>` (`-u` sets upstream if it isn't set). If the branch already tracks a different remote, push to that one instead of assuming `origin`.
- Report the result — confirm success or surface any errors

## Notes

- Never use `--no-verify`. If a pre-commit hook fails, fix the underlying issue and create a **new** commit. Do not `--amend` a failed-hook commit — that commit did not happen.
- Never force-push unless the user explicitly asks for it. If the push is **rejected as non-fast-forward**, stop and report it — the remote has commits you don't. Ask before pulling, rebasing, or forcing.
