#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$HOME/bestie_ai"
./boot.sh >/dev/null 2>&1 || true

# Feature flags (defaults)
ENABLE_PERPLEXITY="${ENABLE_PERPLEXITY:-0}"
ENABLE_GEMINI="${ENABLE_GEMINI:-1}"
ENABLE_HF="${ENABLE_HF:-1}"

# Safety
RL_GEM_MAX="${RL_GEM_MAX:-60}"
RL_GEM_WIN="${RL_GEM_WIN:-3600}"
FAIL_MAX="${FAIL_MAX:-3}"
BLOCK_MIN="${BLOCK_MIN:-10}"

log_health(){ echo "$(date -u +'%F %T UTC') — $*" >> HEALTH.log; }
have(){ [ -n "$1" ]; }

# Fail-safe helpers
./fail_safe.sh check >/dev/null 2>&1 || true
exp="$(./fail_safe.sh check || echo 0)"
now="$(date +%s)"
if [ -n "$exp" ] && [ "$exp" != "0" ] && [ "$exp" -gt "$now" ]; then
  rem=$((exp-now))
  echo "(safe) router temporarily blocked: ${rem}s left"; log_health "router safe-block active (${rem}s left)"; exit 88
fi

call_perplexity(){
  [ "$ENABLE_PERPLEXITY" = "1" ] && have "${PERPLEXITY_API_KEY:-}" || return 3
  python bestie.py -p perplexity -m "${PERPLEXITY_MODEL:-sonar-pro}" "$@" || return $?
}
call_gemini(){
  [ "$ENABLE_GEMINI" = "1" ] && have "${GEMINI_API_KEY:-}" || return 3
  ./rate_guard.sh gemini "$RL_GEM_MAX" "$RL_GEM_WIN" || return $?
  python "$HOME/bestie_ai/gemini_cli.py" "$@" || return $?
}
call_hf(){
  [ "$ENABLE_HF" = "1" ] || return 3
  python "$HOME/bestie_ai/hf_cli.py" "$@" || return $?
}

ok=0
# Order: Perplexity -> Gemini -> HuggingFace
if [ "$ENABLE_PERPLEXITY" = "1" ] && have "${PERPLEXITY_API_KEY:-}"; then
  if call_perplexity "$@"; then ok=1; fi
fi
if [ "$ok" = "0" ] && [ "$ENABLE_GEMINI" = "1" ] && have "${GEMINI_API_KEY:-}"; then
  if call_gemini "$@"; then ok=1; fi
fi
if [ "$ok" = "0" ] && [ "$ENABLE_HF" = "1" ]; then
  if call_hf "$@"; then ok=1; fi
fi

if [ "$ok" = "1" ]; then ./fail_safe.sh reset >/dev/null 2>&1 || true; exit 0; fi
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

# --- HF quick health gate (skip on 401/404) ---
hf_quick_check() {
  [ "${ENABLE_HF:-0}" = "1" ] || return 1
  [ -n "${HF_TOKEN:-}" ] || return 1
  local model="${HF_MODEL:-gpt2}"
  local task="${HF_TASK:-text-generation}"
  # tiny HEAD-style ping (POST with 0 max tokens)
  code=$(curl -s -o /dev/null -w '%{http_code}' \
    -H "Authorization: Bearer $HF_TOKEN" -H 'Content-Type: application/json' \
    -X POST "https://router.huggingface.co/hf-inference/${task}?model=${model}" \
    -d '{"inputs":"ping","parameters":{"max_new_tokens":1}}' || echo 599)
  case "$code" in
    200) return 0 ;;
    401|403|404|5*) return 1 ;;
    *) return 1 ;;
  esac
}

# prefer Gemini; HF only if healthy
if [ "$ok" = "0" ] && [ "${ENABLE_HF:-0}" = "1" ] && hf_quick_check; then
  if call_hf "$@"; then ok=1; fi
fi
