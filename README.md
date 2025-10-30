# Bestie AI Hub (Mobile)
Mobile-native AI CLI (Termux) powered by Perplexity. Stable, fast, reproducible.

## Commands
- `bestie "text"` — chat
- `bestie -yt "brief"` — Title/Hook/Captions
- `bestie -yt3 "brief"` — 3 variants
- `bestie -bio "brief"` — mythic third-person bio
- `bestie -plan "focus"` — 7-day Tactical Elite plan

## One-tap ops
- `bboot` → load venv + .env
- `bhealth` → sanity ping + log tail
- `bsync` → pull/rebase + commit + push
- `byt|bbio|bplan` → quick generate
- `byt3|bbio_save|bplan_save` → saves to /outputs
- `backup_env.sh` → local .env snapshot (never pushed)

> Secrets live only in `.env` (ignored by git).
## Quickstart (2 min)
1) **Install Termux** → run:
   termux-setup-storage
   pkg install -y git
   git clone https://github.com/WhadupCleve/bestie-ai-hub.git ~/bestie_ai
   cd ~/bestie_ai
   bash restore.sh

2) **Add keys (local only)**:
   nano .env
   # GEMINI_API_KEY=AIza...
   # PERPLEXITY_API_KEY=sk-...

3) **Go**:
   bboot && bstatus
   br "Say: ROUTER ONLINE"
   bytg "Ohio State night game in the Shoe; no hashtags"

## Safety knobs (defaults)
- Rate limit: RL_GEM_MAX=60 calls / RL_GEM_WIN=3600s
- Auto-block after fails: FAIL_MAX=3, cool-down BLOCK_MIN=10m
Check anytime: bsafety or bself

