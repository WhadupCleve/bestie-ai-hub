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
