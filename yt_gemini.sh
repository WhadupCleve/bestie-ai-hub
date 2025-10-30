#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null

BRIEF="$*"
PROMPT="Return a short video brief with exactly:
Title: <one line>
Hook: <one line>
Captions:
- <short line 1>
- <short line 2>
- <short line 3>
Keep it fierce, punchy, and clean. No hashtags. Context: $BRIEF"

python gemini_cli.py "$PROMPT"
