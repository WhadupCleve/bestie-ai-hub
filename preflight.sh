#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$HOME/bestie_ai"; ./boot.sh >/dev/null 2>&1 || true
echo "=== PREFLIGHT ==="
command -v python >/dev/null && python -V || echo "python missing"
for f in router.sh rate_guard.sh fail_safe.sh safety_status.sh gemini_cli.py; do
  [ -x "$f" ] || echo "WARN: $f missing or not executable"
done
echo "Env flags:"
echo "  ENABLE_PERPLEXITY=${ENABLE_PERPLEXITY:-0}"
echo "  ENABLE_GEMINI=${ENABLE_GEMINI:-1}"
echo "Keys:"
echo "  PERPLEXITY: $([ -n "${PERPLEXITY_API_KEY:-}" ] && echo present || echo MISSING)"
echo "  GEMINI:     $([ -n "${GEMINI_API_KEY:-}" ] && echo present || echo MISSING)"
echo "=== /PREFLIGHT ==="
