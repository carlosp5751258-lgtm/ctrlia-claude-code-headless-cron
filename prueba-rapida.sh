#!/usr/bin/env bash
# Prueba rápida de claude -p con salida JSON y esquema. Ejecútalo dentro de un repositorio git.
set -euo pipefail

claude -p "Resume en español los commits de las últimas 24 horas (git log --since=24.hours --oneline)." \
  --model haiku --max-turns 4 \
  --permission-prompts none \
  --allowedTools "Bash(git log *)" \
  --no-session-persistence \
  --output-format json \
  --json-schema '{"type":"object","properties":{"resumen":{"type":"string"},"commits":{"type":"integer"}},"required":["resumen","commits"]}' \
  < /dev/null | jq '.structured_output'
