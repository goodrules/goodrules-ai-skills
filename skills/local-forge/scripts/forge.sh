#!/usr/bin/env bash
# local-forge: local generation + large-context queries via Qwen3-Coder.
# Qwen generates; Claude reviews and applies. Never drives file edits itself.
set -euo pipefail

MODEL="qwen3-coder:30b"
ENDPOINT="http://localhost:11434/v1/chat/completions"
TAGS="http://localhost:11434/api/tags"

usage() {
  cat <<'EOF'
Usage: forge.sh <mode> [args]
  Modes:
    tests  <file>        Generate unit tests for a source file
    docs   <file>        Draft docstrings/comments (outputs the full annotated file)
    commit               Draft a commit message from staged diff (git diff --cached)
    ask    "question"    Answer a question; pipe file context via stdin
    raw    "prompt"      Arbitrary prompt; optional stdin context

  Examples:
    forge.sh tests src/portfolio.py
    forge.sh commit
    cat src/*.py | forge.sh ask "Where do we open DB sessions and are any left unclosed?"
EOF
}

MODE="${1:-}"; shift || true
[[ -z "$MODE" ]] && { usage; exit 1; }

if ! curl -sf -o /dev/null "$TAGS"; then
  echo "ERROR: Ollama not reachable at localhost:11434. Start it with:  ollama serve" >&2
  exit 3
fi

# call <system> <user>
call() {
  jq -n --arg model "$MODEL" --arg s "$1" --arg u "$2" \
    '{model:$model, messages:[{role:"system",content:$s},{role:"user",content:$u}]}' \
  | curl -sf "$ENDPOINT" -H "Content-Type: application/json" -d @- \
  | jq -r '.choices[0].message.content'
}

case "$MODE" in
  tests)
    F="${1:?need a file}"; [[ -f "$F" ]] || { echo "No such file: $F" >&2; exit 1; }
    call "You write focused, correct unit tests. Match the project's existing test framework and style if visible in the code. Cover happy paths, edge cases, and error conditions. Output only the test code, no prose." \
         "Write unit tests for this file ($F):

$(cat "$F")"
    ;;
  docs)
    F="${1:?need a file}"; [[ -f "$F" ]] || { echo "No such file: $F" >&2; exit 1; }
    call "You add clear, accurate docstrings and comments. Do NOT change any logic. Output the full file with docstrings added and nothing else." \
         "Add docstrings/comments to this file ($F):

$(cat "$F")"
    ;;
  commit)
    DIFF="$(git diff --cached)"
    [[ -z "$DIFF" ]] && { echo "No staged changes (git diff --cached is empty)." >&2; exit 2; }
    call "You write concise conventional-commit messages: one summary line (<=72 chars), a blank line, then terse bullets covering what changed and why. Output only the message." \
         "Draft a commit message for this staged diff:

$DIFF"
    ;;
  ask)
    Q="${1:?need a question}"; CTX=""
    [[ ! -t 0 ]] && CTX="$(cat)"
    call "You answer questions about a codebase precisely, citing file/function/line where you can. If the answer isn't in the provided context, say so plainly rather than guessing." \
         "Question: $Q

Context:
$CTX"
    ;;
  raw)
    P="${1:?need a prompt}"; CTX=""
    [[ ! -t 0 ]] && CTX="$(cat)"
    call "You are a precise, terse local coding assistant." \
         "$P

$CTX"
    ;;
  *)
    echo "Unknown mode: $MODE" >&2; usage; exit 1;;
esac
