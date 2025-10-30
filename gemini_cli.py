#!/data/data/com.termux/files/usr/bin/env python
import os, sys, requests, json

KEY = os.getenv("GEMINI_API_KEY")
if not KEY:
    print("❌ No GEMINI_API_KEY in .env (use: nano .env)"); sys.exit(1)

MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")
prompt = " ".join(sys.argv[1:]).strip() or "Say: PANDAS ONLINE"

url = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={KEY}"
payload = {"contents":[{"parts":[{"text": prompt}]}]}

try:
    r = requests.post(url, json=payload, timeout=45)
    r.raise_for_status()
    data = r.json()
    text = data["candidates"][0]["content"]["parts"][0]["text"]
    print(text.strip())
except Exception as e:
    print("❌ Gemini request failed:", e)
    try: print(json.dumps(r.json(), indent=2)[:1200])
    except: pass
    sys.exit(2)
