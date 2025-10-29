#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
mkdir -p outputs
CSV="outputs/meds.csv"
[ -f "$CSV" ] || echo "date_utc,name,dose,notes" > "$CSV"
if [ $# -lt 2 ]; then
  echo "Usage: bcare_med \"Name\" \"Dose\" [notes...]"
  exit 1
fi
DATE="$(date -u +'%Y-%m-%d %H:%M:%S')"
NAME="$1"; shift
DOSE="$1"; shift
NOTES="$*"
printf '%s,"%s","%s","%s"\n' "$DATE" "$NAME" "$DOSE" "$NOTES" >> "$CSV"
echo "🧪 Med logged → $NAME $DOSE"
