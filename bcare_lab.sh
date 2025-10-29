#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
mkdir -p outputs
CSV="outputs/labs.csv"
[ -f "$CSV" ] || echo "date_utc,test,value,units,reference,notes" > "$CSV"
if [ $# -lt 3 ]; then
  echo "Usage: bcare_lab \"Test\" value units [reference] [notes...]"
  exit 1
fi
DATE="$(date -u +'%Y-%m-%d %H:%M:%S')"
TEST="$1"; shift
VAL="$1"; shift
UNITS="$1"; shift
REF="${1:-}"; [ -n "$1" ] && shift
NOTES="$*"
printf '%s,"%s","%s","%s","%s","%s"\n' "$DATE" "$TEST" "$VAL" "$UNITS" "$REF" "$NOTES" >> "$CSV"
echo "📊 Lab logged → $TEST = $VAL $UNITS"
