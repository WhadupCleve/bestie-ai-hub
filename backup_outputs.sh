#!/data/data/com.termux/files/usr/bin/bash
set -e
DEST="$HOME/storage/shared/Download/BestieAI"
mkdir -p "$DEST"
cp -a ~/bestie_ai/outputs/* "$DEST"/ 2>/dev/null || true
echo "💾 Outputs copied to: $DEST"
