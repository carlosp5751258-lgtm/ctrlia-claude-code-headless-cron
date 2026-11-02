#!/usr/bin/env bash
# Daily commit summary with Claude Code in headless mode
set -euo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
# Server without a browser: uncomment if you use a token from claude setup-token
# source "$HOME/.config/claude-token.env"

command -v jq > /dev/null || { echo "jq is missing: install it with sudo apt install jq" >&2; exit 1; }

PROJECT="${PROJECT:-$HOME/projects/my-app}"
DEST="${DEST:-$HOME/reports}"
mkdir -p "$DEST"
cd "$PROJECT"

output="$DEST/git-$(date +%F).json"
claude -p "Summarize in English the commits from the last 24 hours (use git log --since=24.hours --stat). Group them by topic and mark anything that looks risky with [REVIEW]. If there are no commits, say so in one line." \
  --model haiku \
  --max-turns 6 \
  --max-budget-usd 0.50 \
  --permission-prompts none \
  --allowedTools "Bash(git log *)" \
  --no-session-persistence \
  --output-format json \
  < /dev/null > "$output"

# Fails (and cron writes it to the log) if the run ended in an error
jq -e '.is_error == false' "$output" > /dev/null
jq -r '.result' "$output" > "${output%.json}.md"
