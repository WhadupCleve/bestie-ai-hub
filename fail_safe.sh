#!/data/data/com.termux/files/usr/bin/bash
# Helpers: increment/reset fail count, set/read block
set -euo pipefail
STATE="$HOME/bestie_ai/.state"; mkdir -p "$STATE"
COUNT="$STATE/fail_count"
BLOCK="$STATE/auto_block"     # stores "expiry_epoch"

cmd="${1:-}"
now=$(date +%s)

case "$cmd" in
  inc)
    n=0; [ -f "$COUNT" ] && n=$(cat "$COUNT" 2>/dev/null || echo 0)
    n=$((n+1)); echo "$n" > "$COUNT"; echo "$n"
    ;;
  reset)
    echo 0 > "$COUNT"; rm -f "$BLOCK"; echo 0
    ;;
  block)
    mins="${2:-10}"
    exp=$((now + mins*60))
    echo "$exp" > "$BLOCK"
    echo "$exp"
    ;;
  check)
    if [ -f "$BLOCK" ]; then
      exp=$(cat "$BLOCK" 2>/dev/null || echo 0)
      if [ "$now" -lt "$exp" ]; then
        echo "$exp"; exit 10
      fi
    fi
    echo 0
    ;;
  *)
    echo "usage: $0 {inc|reset|block [mins]|check}" >&2; exit 2
    ;;
esac
