#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$HOME/bestie_ai"; ./boot.sh >/dev/null 2>&1 || true

echo "===== SAFETY STATUS ====="
echo "Provider flags:"
echo "  ENABLE_PERPLEXITY=${ENABLE_PERPLEXITY:-0}"
echo "  ENABLE_GEMINI=${ENABLE_GEMINI:-1}"
echo
echo "Limits:"
echo "  RL_GEM_MAX=${RL_GEM_MAX:-60} calls"
echo "  RL_GEM_WIN=${RL_GEM_WIN:-3600}s"
echo "  FAIL_MAX=${FAIL_MAX:-3}"
echo "  BLOCK_MIN=${BLOCK_MIN:-10}m"
echo

STATE="$HOME/bestie_ai/.state"
FC="$STATE/fail_count"; [ -f "$FC" ] || echo 0 > "$FC"
echo "Fail count: $(cat "$FC")"

BL="$STATE/auto_block"
if [ -f "$BL" ]; then
  exp=$(cat "$BL" 2>/dev/null || echo 0)
  now=$(date +%s)
  if [ "$exp" -gt "$now" ]; then
    rem=$((exp-now))
    iso="$(date -u -d "@$exp" +'%F %T UTC' 2>/dev/null || busybox date -u -D %s -d "$exp" +'%F %T UTC')"
    echo "Auto-block: ACTIVE (until $iso, ~${rem}s)"
  else
    echo "Auto-block: expired"; rm -f "$BL"
  fi
else
  echo "Auto-block: none"
fi

CACHE="$HOME/.cache/bestie_ai/rl_gemini.log"
if [ -f "$CACHE" ]; then
  echo
  echo "Recent Gemini calls (windowed):"
  tail -n 5 "$CACHE" | awk '{print strftime("%F %T UTC", $1)}'
fi
echo "=========================="
