#!/bin/bash
# Installs the claude-video watch plugin in cloud sessions, whose containers start fresh.
[ "$CLAUDE_CODE_REMOTE" = "true" ] || exit 0
cd "$CLAUDE_PROJECT_DIR" || exit 0

if ! claude plugin list 2>/dev/null | grep -q 'watch@claude-video'; then
  # The install rewrites settings.json; keep the committed formatting.
  BACKUP=$(mktemp)
  cp .claude/settings.json "$BACKUP"
  claude plugin marketplace add bradautomates/claude-video >/dev/null 2>&1
  claude plugin install watch@claude-video --scope project >/dev/null 2>&1
  cp "$BACKUP" .claude/settings.json
  rm -f "$BACKUP"
fi

command -v yt-dlp >/dev/null || pip install -q yt-dlp >/dev/null 2>&1

SETUP=$(ls -d ~/.claude/plugins/cache/claude-video/watch/*/skills/watch/scripts/setup.py 2>/dev/null | tail -1)
[ -n "$SETUP" ] && [ -n "$GEMINI_API_KEY" ] && python3 "$SETUP" --engine gemini >/dev/null 2>&1
exit 0
