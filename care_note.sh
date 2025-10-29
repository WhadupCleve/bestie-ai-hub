#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
mkdir -p outputs
TS=$(date -u +'%Y-%m-%d %H:%M:%S UTC')
NOTE="$*"
if [ -z "$NOTE" ]; then
  echo "Usage: bcare_note \"what happened / symptoms / context\""
  exit 1
fi
FILE=outputs/care_notes.csv
[ -f "$FILE" ] || echo "timestamp,note" > "$FILE"
printf "%s,%s\n" "$TS" "$(echo "$NOTE" | tr '\n' ' ' | sed 's/,/;/g')" >> "$FILE"
echo "📝 Saved: $TS — $NOTE"
