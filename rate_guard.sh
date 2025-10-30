#!/data/data/com.termux/files/usr/bin/bash
# Usage: rate_guard.sh <tag> [MAX] [WINDOW_SECS]
set -euo pipefail
TAG="${1:-gemini}"
MAX="${2:-60}"           # default max calls per window
WIN="${3:-3600}"         # default 1h window
CACHE="$HOME/.cache/bestie_ai"; mkdir -p "$CACHE"
LOG="$CACHE/rl_${TAG}.log"
NOW=$(date +%s)

# prune old entries
touch "$LOG"
awk -v now="$NOW" -v win="$WIN" '$1 >= now-win' "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"

COUNT=$(wc -l < "$LOG")
if [ "$COUNT" -ge "$MAX" ]; then
  OLDEST=$(head -n1 "$LOG" | awk '{print $1}')
  HOLD=$((WIN - (NOW - OLDEST)))
  echo "(rate-limit) ${TAG}: hold ${HOLD}s (max ${MAX}/${WIN}s window)"
  exit 89
fi

echo "$NOW" >> "$LOG"
exit 0
