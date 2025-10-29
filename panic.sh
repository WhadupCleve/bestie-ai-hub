#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
# Enter safe mode
./safe_mode.sh on
# Kill common long-running things
pkill -f "http.server" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "python .*app.py" 2>/dev/null || true
# leave watcher tmux alone so health keeps logging
echo "🛑 PANIC: everything halted, safe mode ON"
