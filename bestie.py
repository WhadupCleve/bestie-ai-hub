import os, sys, re, requests
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.getenv("PERPLEXITY_API_KEY","").strip()
MODEL   = os.getenv("PERPLEXITY_MODEL","sonar-pro").strip()

def ask_perplexity(messages, temperature=0.4, timeout=60):
    if not API_KEY:
        return "❌ Missing PERPLEXITY_API_KEY in .env"
    url = "https://api.perplexity.ai/chat/completions"
    headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
    payload = {"model": MODEL, "messages": messages, "temperature": temperature, "stream": False}
    r = requests.post(url, headers=headers, json=payload, timeout=timeout)
    if r.status_code != 200:
        return f"❌ HTTP {r.status_code}: {r.text[:800]}"
    j = r.json()
    content = (j.get("choices",[{}])[0].get("message",{}) or {}).get("content","")
    return re.sub(r"\[\d+\]", "", content or "").strip()

def chat_mode(text: str) -> str:
    msgs = [
        {"role":"system","content":"You are Bestie 🐼 — precise, helpful, casual. No citation markers."},
        {"role":"user","content":text}
    ]
    return ask_perplexity(msgs, temperature=0.4)

def bio_mode(brief: str) -> str:
    sysmsg = ("You write public-facing bios in a mythic/oracle tone—calm, inevitable, elite. "
              "Output clean third-person prose only (no lists/quotes/emojis/citations). "
              "130–180 words in 2–3 compact paragraphs. Emphasize mobile-native AI systems, "
              "multi-model orchestration, API-first engineering.")
    prompt = f"""
Write a third-person bio for Matthew David Cargnel (aka Cleveland/Cleve).
Profile: underground-leaning AI builder who engineered multi-agent orchestration from mobile-only infrastructure.
Mention: Hugging Face Spaces (mobile), Termux Python CLI, API integrations (Perplexity first; OpenAI/Groq/Mistral when available),
GitHub/HF workflow, operational discipline. No quotes/emoji/bullets. Close on shipping stable systems.
User brief: {brief.strip()}
""".strip()
    return ask_perplexity(
        [{"role":"system","content":sysmsg},{"role":"user","content":prompt}],
        temperature=0.3
    )

def yt_mode(brief: str) -> str:
    sysmsg = ("You generate short-form video copy that converts. "
              "Output ONLY: Title:, Hook:, Captions:. Titles 8–12 words, no emojis. "
              "Hook <=12 words. Captions: 3 lines, each <100 chars, no hashtags unless asked.")
    prompt = f"""
Create a high-converting short-form package for this brief:

{brief.strip()}

Return exactly:
Title: <one line>
Hook: <one line>
Captions:
- <line 1>
- <line 2>
- <line 3>
""".strip()
    return ask_perplexity(
        [{"role":"system","content":sysmsg},{"role":"user","content":prompt}],
        temperature=0.5
    )

def plan_mode(brief: str) -> str:
    sysmsg = ("You are an operator-grade planner. Output a 7-day Tactical Elite mission brief. "
              "Format strictly: OPERATION: OPERATION-PLAN / OVERVIEW: <one line> then DAY n // OBJECTIVE: ... "
              "Then TOOLS: <csv>; TASKS: - <1> - <2> - <3>; MEASURABLE: <one metric>. "
              "Tone concise, commanding, practical. No emojis or quotes.")
    prompt = f"""
OPERATION: OPERATION-PLAN
OVERVIEW: Tactical Elite 7-day plan — focus: {brief.strip()}

Produce DAYS 1..7. Each day:
DAY <n> // OBJECTIVE: <one sentence>
TOOLS: <csv tools>
TASKS:
- <task 1>
- <task 2>
- <task 3>
MEASURABLE: <single metric>

Stack focus: Termux Python, Hugging Face Spaces (mobile), GitHub, PERPLEXITY API, lightweight local tooling.
""".strip()
    return ask_perplexity(
        [{"role":"system","content":sysmsg},{"role":"user","content":prompt}],
        temperature=0.25
    )

def main():
    if len(sys.argv) <= 1:
        print('Usage:\n  bestie "message"\n  bestie -bio "context"\n  bestie -yt "video brief"\n  bestie -plan "focus"')
        return

    mode = sys.argv[1]
    if mode == "-bio":
        print(bio_mode(" ".join(sys.argv[2:]).strip() or "Mobile-only HF Spaces + Termux; multi-model orchestration.")); return
    if mode == "-yt":
        print(yt_mode(" ".join(sys.argv[2:]).strip() or "Ohio State hype; 12–20s vertical; fierce; no hashtags.")); return
    if mode == "-plan":
        print(plan_mode(" ".join(sys.argv[2:]).strip() or "Harden mobile multi-model orchestration with reproducible wins.")); return

    print(chat_mode(" ".join(sys.argv[1:])))

if __name__ == "__main__":
    main()
