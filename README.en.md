# Claude Code headless: `claude -p` in scripts and cron

[Leer en español](README.md)

The Spanish version is in the repository root and in [README.md](README.md); the English files are in `en/`.

A copy-and-paste script that asks Claude Code, without opening its interface, for a daily summary of the last 24 hours of commits and saves it as Markdown. Minimal permissions (only `git log`), turn and spend caps, the Haiku model and JSON output checked with `jq`.

The step-by-step explanation (permissions in `-p`, login under cron, the usage warning from issue #97074) is in the recipe:

- English: https://ctrlia.dev/en/recetas/claude-code-headless-cron.html
- Español: https://ctrlia.dev/recetas/claude-code-headless-cron.html

## What's inside

| File | What for |
| --- | --- |
| `en/git-summary.sh` | The cron script: daily commit summary in `~/reports/git-YYYY-MM-DD.md` |
| `en/quick-test.sh` | Quick test of `claude -p` with `--json-schema` (returns `structured_output`) |
| `en/crontab.txt` | The crontab line: Monday to Friday at 7:30, with `flock` |

## How to use it

You need Claude Code with a logged-in session (`claude`, then `/login`) and `jq` (`sudo apt install jq`).

```bash
mkdir -p ~/bin ~/reports
cp en/git-summary.sh ~/bin/git-summary.sh
chmod +x ~/bin/git-summary.sh
# Edit PROJECT inside the script (or pass it as a variable) and run it by hand:
PROJECT="$HOME/projects/my-app" ~/bin/git-summary.sh && cat ~/reports/git-$(date +%F).md
# If it works, add the line from en/crontab.txt with: crontab -e
```

`PROJECT` (repository) and `DEST` (output folder) can be passed as environment variables; otherwise the script uses `~/projects/my-app` and `~/reports`.

### Server without a browser

```bash
# On your PC (opens the browser once and prints the token; it does not store it)
claude setup-token

# On the server: keep it outside the repository and readable only by you
install -m 600 /dev/null ~/.config/claude-token.env
echo 'export CLAUDE_CODE_OAUTH_TOKEN=paste-the-token-here' > ~/.config/claude-token.env
```

Then uncomment the `source "$HOME/.config/claude-token.env"` line in `git-summary.sh`. Never commit that file.

## Usage warning

Issue [#97074](https://github.com/anthropics/claude-code/issues/97074) (open) measures that `claude -p` uses about 1.8 times more of the 5-hour window than the interactive session with the same tokens. Anthropic has not confirmed it: use Haiku, cap turns and watch `/usage` during the first week.

## What was tested

With Claude Code **2.1.316** on Linux: the call's flags, `--json-schema` with `structured_output`, permission denial with `--permission-prompts none` and the stdin warning without `< /dev/null`. The script was checked with `bash -n` and by running it with a simulated `claude` and `jq` (it writes the `.json` and the `.md`, and exits with an error if `is_error` is `true` or `jq` is missing). It has not been tested with the real `jq` or by leaving the cron line running for a full day.

## License

MIT. See [LICENSE](LICENSE).

---
Part of **[Ctrl+IA](https://ctrlia.dev/en/)**: code with Claude Code like a pro. Made by Carlos P.
