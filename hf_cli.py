#!/data/data/com.termux/files/usr/bin/env python
import os, sys, json, requests

token  = os.getenv("HF_TOKEN", "")
model  = os.getenv("HF_MODEL", "Qwen/Qwen2.5-0.5B-Instruct")
task   = os.getenv("HF_TASK", "text-generation")
prompt = " ".join(sys.argv[1:]).strip() or "Say: HUGGING FACE ONLINE"

if not token:
    print("❌ HF_TOKEN missing (add to .env)"); sys.exit(2)

url = f"https://router.huggingface.co/hf-inference/{task}"
params = {"model": model}
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
payload = {"inputs": prompt, "parameters": {"max_new_tokens": 64}}

try:
    r = requests.post(url, params=params, headers=headers, json=payload, timeout=45)
    r.raise_for_status()
    data = r.json()

    # Try common result shapes
    out = None
    if isinstance(data, dict):
        out = data.get("generated_text") or data.get("text")
        if not out and "results" in data and data["results"]:
            out = data["results"][0].get("generated_text") or data["results"][0].get("text")
    elif isinstance(data, list) and data:
        out = data[0].get("generated_text") or data[0].get("text")

    if not out:
        out = data  # fallback: print raw JSON
        if not isinstance(out, str):
            out = json.dumps(out, ensure_ascii=False)

    print(out.strip()[:1200])
except Exception as e:
    print("❌ HF request failed:", e)
    try:
        print(json.dumps(r.json(), indent=2)[:1200])
    except Exception:
        pass
    sys.exit(2)
