#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$HOME/bestie_ai"

# Load venv + .env silently
./boot.sh >/dev/null 2>&1 || true

# Defaults
ENABLE_PERPLEXITY="${ENABLE_PERPLEXITY:-0}"
ENABLE_GEMINI="${ENABLE_GEMINI:-1}"   # Gemini ON by default

# Safety knobs (override via .env)
RL_GEM_MAX="${RL_GEM_MAX:-60}"        # calls per window
RL_GEM_WIN="${RL_GEM_WIN:-3600}"      # window seconds
FAIL_MAX="${FAIL_MAX:-3}"             # consecutive failures to trigger block
BLOCK_MIN="${BLOCK_MIN:-10}"          # cool-down minutes

log_health() { echo "$(date -u +'%F %T UTC') — $*" >> HEALTH.log; }

# Check auto-block
if ./fail_safe.sh check >/dev/null 2>&1; then
  :
fi
if exp=$(./fail_safe.sh check) ; then :; fi
if [ -n "$exp" ] && [ "$exp" != "0" ]; then
  remaining=$(( exp - $(date +%s) ))
  if [ "$remaining" -gt 0 ]; then
    echo "(safe) router temporarily blocked: ${remaining}s left"
    log_health "router safe-block active (${remaining}s left)"
    exit 88
  fi
fi

have() { [ -n "$1" ]; }

# --- Providers ---
call_perplexity() {
  [ "$ENABLE_PERPLEXITY" = "1" ] && have "${PERPLEXITY_API_KEY:-}" || return 3
  python bestie.py -p perplexity -m "${PERPLEXITY_MODEL:-sonar-pro}" "$@" || return $?
}

call_gemini() {
  [ "$ENABLE_GEMINI" = "1" ] && have "${GEMINI_API_KEY:-}" || return 3
  # rate-limit Gemini
  ./rate_guard.sh gemini "$RL_GEM_MAX" "$RL_GEM_WIN" || return $?
  python "$HOME/bestie_ai/gemini_cli.py" "$@" || return $?
}

# --- Routing order ---
ok=0

# Primary (Perplexity) if enabled
if [ "$ENABLE_PERPLEXITY" = "1" ] && have "${PERPLEXITY_API_KEY:-}"; then
  if call_perplexity "$@"; then ok=1; fi
fi

# Fallback (Gemini)
if [ "$ok" = "0" ]; then
  if call_gemini "$@"; then ok=1; fi
fi

# Result handling
if [ "$ok" = "1" ]; then
  ./fail_safe.sh reset >/dev/null 2>&1 || true
  exit 0
fi

# Failure path: increment and maybe block
n=$(./fail_safe.sh inc)
if [ "$n" -ge "$FAIL_MAX" ]; then
  exp=$(./fail_safe.sh block "$BLOCK_MIN")
  iso="$(date -u -d "@$exp" +'%F %T UTC' 2>/dev/null || busybox date -u -D %s -d "$exp" +'%F %T UTC')"
  echo "(safe) too many failures — cooling down until ${iso}"
  log_health "router auto-block (${FAIL_MAX}x fail) until ${iso}"
else
  echo "(router) failed (consecutive: ${n}/${FAIL_MAX})"
  log_health "router failure ${n}/${FAIL_MAX}"
fi
exit 2
