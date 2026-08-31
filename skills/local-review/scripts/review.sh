#!/usr/bin/env bash
# local-review: independent second-opinion critique from a local Gemma 4 model.
# Read-only. Content comes from --file, --image, or stdin.
set -euo pipefail

MODEL="gemma4:26b"
ENDPOINT="http://localhost:11434/v1/chat/completions"
TAGS="http://localhost:11434/api/tags"
FOCUS="Give a critical, independent second-opinion review. Flag bugs, edge cases, security issues, unclear logic, missing error handling, and risky assumptions. Be specific and terse. Do not rubber-stamp."
FILE=""
IMAGE=""

usage() {
  cat <<'EOF'
Usage: review.sh [--focus "what to look for"] [--file PATH] [--image PATH]
  Content to review comes from --file, --image, or stdin (e.g. a piped diff).

  Examples:
    git diff --cached | review.sh --focus "concurrency and error handling"
    review.sh --file src/auth.py
    review.sh --image screenshot.png --focus "UI/UX and accessibility"
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --focus) FOCUS="$2"; shift 2;;
    --file)  FILE="$2";  shift 2;;
    --image) IMAGE="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

if ! curl -sf -o /dev/null "$TAGS"; then
  echo "ERROR: Ollama not reachable at localhost:11434. Start it with:  ollama serve" >&2
  exit 3
fi

SYSTEM="You are a sharp, independent code/design reviewer giving a SECOND OPINION. You did not write this work. Find real problems: bugs, race conditions, edge cases, security holes, unclear logic, missing error handling, bad assumptions. Be specific, point to the relevant line or section, and be terse. Most important issues first. If something is genuinely fine, say so briefly instead of inventing nits."

if [[ -n "$IMAGE" ]]; then
  [[ -f "$IMAGE" ]] || { echo "No such image: $IMAGE" >&2; exit 1; }
  B64="$(base64 < "$IMAGE" | tr -d '\n')"
  shopt -s nocasematch
  case "$IMAGE" in
    *.jpg|*.jpeg) MIME="image/jpeg";;
    *.gif)        MIME="image/gif";;
    *.webp)       MIME="image/webp";;
    *)            MIME="image/png";;
  esac
  shopt -u nocasematch
  PAYLOAD="$(jq -n --arg model "$MODEL" --arg system "$SYSTEM" --arg focus "$FOCUS" \
    --arg url "data:$MIME;base64,$B64" \
    '{model:$model, messages:[
       {role:"system", content:$system},
       {role:"user", content:[
         {type:"text", text:$focus},
         {type:"image_url", image_url:{url:$url}}
       ]}
     ]}')"
else
  if [[ -n "$FILE" ]]; then
    [[ -f "$FILE" ]] || { echo "No such file: $FILE" >&2; exit 1; }
    CONTENT="$(cat "$FILE")"; HEADER="Reviewing file: $FILE"
  elif [[ ! -t 0 ]]; then
    CONTENT="$(cat)"; HEADER="Reviewing piped content:"
  else
    echo "No content given. Use --file, --image, or pipe via stdin." >&2
    usage; exit 1
  fi
  USERMSG="$FOCUS

$HEADER
$CONTENT"
  PAYLOAD="$(jq -n --arg model "$MODEL" --arg system "$SYSTEM" --arg user "$USERMSG" \
    '{model:$model, messages:[
       {role:"system", content:$system},
       {role:"user", content:$user}
     ]}')"
fi

curl -sf "$ENDPOINT" -H "Content-Type: application/json" -d "$PAYLOAD" \
  | jq -r '.choices[0].message.content'
