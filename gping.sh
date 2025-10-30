#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null
python gemini_cli.py "Reply with exactly: PANDAS ONLINE"
