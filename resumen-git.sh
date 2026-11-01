#!/usr/bin/env bash
# Resumen diario de commits con Claude Code en modo sin interfaz
set -euo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
# Servidor sin navegador: descomenta si usas un token de claude setup-token
# source "$HOME/.config/claude-token.env"

command -v jq > /dev/null || { echo "Falta jq: instálalo con sudo apt install jq" >&2; exit 1; }

PROYECTO="${PROYECTO:-$HOME/proyectos/mi-app}"
DESTINO="${DESTINO:-$HOME/informes}"
mkdir -p "$DESTINO"
cd "$PROYECTO"

salida="$DESTINO/git-$(date +%F).json"
claude -p "Resume en español los commits de las últimas 24 horas (usa git log --since=24.hours --stat). Agrúpalos por tema y marca con [REVISAR] lo que parezca arriesgado. Si no hay commits, dilo en una línea." \
  --model haiku \
  --max-turns 6 \
  --max-budget-usd 0.50 \
  --permission-prompts none \
  --allowedTools "Bash(git log *)" \
  --no-session-persistence \
  --output-format json \
  < /dev/null > "$salida"

# Falla (y cron lo anota en el log) si la ejecución terminó en error
jq -e '.is_error == false' "$salida" > /dev/null
jq -r '.result' "$salida" > "${salida%.json}.md"
