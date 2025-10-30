#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null 2>&1 || true

ENABLE_PERPLEXITY="${ENABLE_PERPLEXITY:-0}"
ENABLE_GEMINI="${ENABLE_GEMINI:-1}"   # default ON now

have() { [ -n "$1" ]; }

backoff_run () {
  # $1 = command (quoted), retries=3
  local i=0
  for i in 0 1 2; do
    eval "$1" && return 0
    sleep $((2**i))   # 1s,2s,4s
  done
  return 1
}

if [ "$ENABLE_PERPLEXITY" = "1" ] && have "${PERPLEXITY_API_KEY:-}"; then
  backoff_run 'python bestie.py -p perplexity -m "${PERPLEXITY_MODEL:-sonar-pro}" "$@"' || {
    echo "(router) Perplexity failed, falling back to Gemini…" >&2
    ENABLE_PERPLEXITY=0
  }
fi

if [ "$ENABLE_PERPLEXITY" != "1" ]; then
  if [ "$ENABLE_GEMINI" = "1" ] && have "${GEMINI_API_KEY:-}"; then
    backoff_run 'python ~/bestie_ai/gemini_cli.py "$@"' && exit 0
  fi
fi

echo "(offline) Both providers unavailable. Check .env flags and keys, then run: bboot && bstatus"
exit 2
