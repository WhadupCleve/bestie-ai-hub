#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai/outputs
FILE="$(ls -t care_bundle_*.html 2>/dev/null | head -n 1)"
if [ -z "$FILE" ]; then
  echo "No care_bundle HTML found. Run: bcare_pdf"
  exit 1
fi
# kill any prior server on 8999
pkill -f "http.server 8999" 2>/dev/null || true
# serve quietly, then open
python -m http.server 8999 >/dev/null 2>&1 &
sleep 0.5
termux-open-url "http://127.0.0.1:8999/$FILE"
echo "📄 Opened: $FILE (served at http://127.0.0.1:8999/)"
