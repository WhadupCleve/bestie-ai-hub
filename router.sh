#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai

# Load venv + .env into *this* shell (must SOURCE, not execute)
# boot.sh should not 'exit'; if it echoes, that's fine.
# If sourcing boot.sh ever fails, fallback-source .env directly.
if ! source ./boot.sh >/dev/null 2>&1; then
  [ -f .env ] && { set -a; source .env; set +a; }
fi

# Defaults if unset
ENABLE_PERPLEXITY="${ENABLE_PERPLEXITY:-0}"
ENABLE_GEMINI="${ENABLE_GEMINI:-}"

# Auto-enable Gemini if a key exists and the flag isn't set
if [ -z "$ENABLE_GEMINI" ]; then
  if [ -n "${GEMINI_API_KEY:-}" ]; then ENABLE_GEMINI=1; else ENABLE_GEMINI=0; fi
fi

have() { [ -n "$1" ]; }

# Perplexity first (only if explicitly enabled and key present)
if [ "$ENABLE_PERPLEXITY" = "1" ] && have "${PERPLEXITY_API_KEY:-}"; then
  python bestie.py -p perplexity -m "${PERPLEXITY_MODEL:-sonar-pro}" "$@" || {
    echo "(router) Perplexity failed, falling back to Gemini…" >&2
    ENABLE_PERPLEXITY=0
  }
fi

# Gemini fallback or primary
if [ "$ENABLE_PERPLEXITY" != "1" ]; then
  if [ "$ENABLE_GEMINI" = "1" ] && have "${GEMINI_API_KEY:-}"; then
    python ~/bestie_ai/gemini_cli.py "$@"
    exit $?
  fi
fi

echo "(offline) Both providers unavailable. Check .env flags and keys, then run: bboot && bstatus"
exit 2
