#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null

if [ -n "${PERPLEXITY_API_KEY:-}" ]; then
  # Defer to original bestie CLI if Perplexity is present
  bestie "$@"
elif [ -n "${GEMINI_API_KEY:-}" ]; then
  # Route to Gemini if Perplexity is missing
  python gemini_cli.py "$*"
else
  echo "❌ No API keys found (need PERPLEXITY_API_KEY or GEMINI_API_KEY in .env)"
  exit 1
fi
