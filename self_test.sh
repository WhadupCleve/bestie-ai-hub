#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$HOME/bestie_ai"; ./boot.sh >/dev/null 2>&1 || true
echo "[1/4] Router ping";   ~/bestie_ai/router.sh "ping" >/dev/null && echo " ok"
echo "[2/4] Gemini ping";   ~/bestie_ai/gping.sh >/dev/null && echo " ok"
echo "[3/4] Safety dash";   ~/bestie_ai/safety_status.sh | head -n 8
echo "[4/4] Rate guard";    RL_GEM_MAX=1 RL_GEM_WIN=10 ~/bestie_ai/router.sh "test" >/dev/null || echo " (expected guarded)"
sleep 1
echo "Done."
