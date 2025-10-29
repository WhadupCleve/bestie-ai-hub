#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null
TS=$(date -u +'%Y%m%d_%H%M%S')
mkdir -p outputs
python bestie.py -bio  "mobile-only AI architect; disciplined shipping" | tee "outputs/bio_${TS}.md"
python bestie.py -yt3  "Ohio State night game in the Shoe; fierce; no hashtags" | tee "outputs/yt_variants_${TS}.md"
python bestie.py -plan "refine orchestration stability; no new API risk" | tee "outputs/plan_${TS}.md"
./sync.sh
echo "✅ Content pack saved & synced at $TS"
