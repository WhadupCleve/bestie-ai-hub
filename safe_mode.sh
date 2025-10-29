#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai

case "$1" in
  on)
    touch SAFE_MODE
    # Seal .env if present
    if [ -f .env ] && [ ! -f .env.sealed ]; then
      mv .env .env.sealed
      printf "# sealed\n" > .env
    fi
    # stop any local servers
    pkill -f "http.server" 2>/dev/null || true
    echo "🔒 SAFE MODE: ON (secrets sealed, servers stopped)"
    ;;
  off)
    rm -f SAFE_MODE
    # Restore .env if sealed
    if [ -f .env.sealed ]; then
      mv .env.sealed .env
    fi
    echo "🔓 SAFE MODE: OFF (secrets restored)"
    ;;
  *)
    echo "Usage: ./safe_mode.sh on|off"
    exit 1
    ;;
esac
