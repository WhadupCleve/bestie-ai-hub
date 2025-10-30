#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai

# Load venv + env quietly
./boot.sh >/dev/null

# 1) Python + CLI
PYV=$(python -V 2>/dev/null || echo "python not found")
CLIV="ok"

# 2) API keys (masked)
PKEY="${PERPLEXITY_API_KEY:-}"
GKEY="${GEMINI_API_KEY:-}"
if [ -n "$PKEY" ]; then PSHOW="Perplexity(****${PKEY: -4})"; else PSHOW="Perplexity(MISSING)"; fi
if [ -n "$GKEY" ]; then GSHOW="Gemini(****${GKEY: -4})"; else GSHOW="Gemini(MISSING)"; fi
API="$PSHOW | $GSHOW"

# 3) Git status
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-branch")
REMOTE=$(git remote get-url origin 2>/dev/null || echo "no remote")
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  GIT="clean"
else
  GIT="dirty"
fi
SB=$(git status -sb 2>/dev/null || true | head -n 1)

# 4) Watcher status
if tmux has-session -t watcher 2>/dev/null; then
  WATCHER="running"
else
  WATCHER="stopped"
fi

# 5) Last health line
LASTH=$(tail -n 1 HEALTH.log 2>/dev/null || echo "no health log yet")

echo "===== BESTIE AI HUB STATUS ====="
echo "Python:     $PYV"
echo "CLI:        $CLIV"
echo "API key:    $API"
echo "Branch:     $BR"
echo "Git:        $GIT  [$SB]"
echo "Remote:     $REMOTE"
echo "Watcher:    $WATCHER"
echo "Last health: $LASTH"
echo "================================"
