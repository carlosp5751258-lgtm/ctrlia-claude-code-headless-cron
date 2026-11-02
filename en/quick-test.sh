#!/usr/bin/env bash
# Quick test of claude -p with JSON output and a schema. Run it inside a git repository.
set -euo pipefail

claude -p "Summarize in English the commits from the last 24 hours (git log --since=24.hours --oneline)." \
  --model haiku --max-turns 4 \
  --permission-prompts none \
  --allowedTools "Bash(git log *)" \
  --no-session-persistence \
  --output-format json \
  --json-schema '{"type":"object","properties":{"summary":{"type":"string"},"commits":{"type":"integer"}},"required":["summary","commits"]}' \
  < /dev/null | jq '.structured_output'
