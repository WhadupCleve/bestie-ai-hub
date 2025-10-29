#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null
TS=$(date -u +'%Y%m%d_%H%M%S')

if [ -z "$1" ]; then
  echo "Usage: bcare \"short concern (e.g., 'LDL high; statin allergy; alternatives?')\""
  exit 1
fi

BRIEF="$1"
mkdir -p outputs

python bestie.py "Create a **patient intake checklist** for this concern: ${BRIEF}.
Sections:
- Symptoms / what to describe
- Info to bring (labs / meds / reactions)
- Red flags (urgent care / ER trigger signs)
Close with: 'Not medical advice — for discussion with a licensed clinician.' " \
| tee "outputs/care_intake_${TS}.md"

python bestie.py "Draft a **doctor-facing neutral summary** for this concern: ${BRIEF}.
Keep it concise, medically respectful, and ready for real doctor context.
Include:
- Reason for visit
- Key known history points
- 5–7 questions to clarify
- 'Ask about' options language
Close with: 'Not medical advice — informational only.'" \
| tee "outputs/care_doctor_brief_${TS}.md"

python bestie.py "Create a **follow-up questions list** a prepared patient could ask.
Must be respectful, concise, focused on understanding, not instructions.
Close with: 'This list is for conversation support only — not medical advice.'" \
| tee "outputs/care_followups_${TS}.md"

./sync.sh
echo "✅ Care Pack saved & synced at $TS"
