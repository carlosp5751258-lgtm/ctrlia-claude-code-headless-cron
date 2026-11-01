# Claude Code headless: `claude -p` en scripts y cron

[Read in English](README.en.md)

Un script listo para copiar que pide a Claude Code, sin abrir su interfaz, un resumen diario de los commits de las últimas 24 horas y lo guarda en Markdown. Con permisos mínimos (solo `git log`), tope de turnos y de gasto, modelo Haiku y salida JSON comprobada con `jq`.

La explicación paso a paso (permisos en `-p`, login en cron, aviso de consumo del issue #97074) está en la receta:

- Español: https://ctrlia.dev/recetas/claude-code-headless-cron.html
- English: https://ctrlia.dev/en/recetas/claude-code-headless-cron.html

## Qué incluye

| Archivo | Para qué |
| --- | --- |
| `resumen-git.sh` | El script de cron: resumen diario de commits en `~/informes/git-AAAA-MM-DD.md` |
| `prueba-rapida.sh` | Prueba de `claude -p` con `--json-schema` (devuelve `structured_output`) |
| `crontab.txt` | La línea de crontab: lunes a viernes a las 7:30, con `flock` |

## Cómo usarlo

Necesitas Claude Code con sesión iniciada (`claude` y luego `/login`) y `jq` (`sudo apt install jq`).

```bash
mkdir -p ~/bin ~/informes
cp resumen-git.sh ~/bin/resumen-git.sh
chmod +x ~/bin/resumen-git.sh
# Edita PROYECTO dentro del script (o pásalo como variable) y pruébalo a mano:
PROYECTO="$HOME/proyectos/mi-app" ~/bin/resumen-git.sh && cat ~/informes/git-$(date +%F).md
# Si funciona, añade la línea de crontab.txt con: crontab -e
```

`PROYECTO` y `DESTINO` se pueden pasar como variables de entorno; si no, el script usa `~/proyectos/mi-app` y `~/informes`.

### Servidor sin navegador

```bash
# En tu PC (abre el navegador una vez y muestra el token; no lo guarda)
claude setup-token

# En el servidor: guárdalo fuera del repositorio y solo legible por ti
install -m 600 /dev/null ~/.config/claude-token.env
echo 'export CLAUDE_CODE_OAUTH_TOKEN=pega-aqui-el-token' > ~/.config/claude-token.env
```

Después descomenta la línea `source "$HOME/.config/claude-token.env"` de `resumen-git.sh`. Nunca subas ese archivo a un repositorio.

## Aviso de consumo

El issue [#97074](https://github.com/anthropics/claude-code/issues/97074) (abierto) mide que `claude -p` gasta unas 1,8 veces más de la ventana de 5 horas que la sesión interactiva con los mismos tokens. No está confirmado por Anthropic: usa Haiku, limita turnos y vigila `/usage` la primera semana.

## Qué se probó

Con Claude Code **2.1.316** en Linux: las banderas de la llamada, `--json-schema` con `structured_output`, la denegación de permisos con `--permission-prompts none` y el aviso de stdin sin `< /dev/null`. El script se comprobó con `bash -n` y ejecutándolo con `claude` y `jq` simulados (crea el `.json` y el `.md`, y sale con error si `is_error` es `true` o si falta `jq`). No se ha probado con el `jq` real ni dejando la línea de cron un día entero.

## Licencia

MIT. Ver [LICENSE](LICENSE).

---
Parte de **[Ctrl+IA](https://ctrlia.dev/)**: programa con Claude Code como un pro, en español. Hecho por Carlos P.
