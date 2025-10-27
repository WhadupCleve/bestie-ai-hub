import os, requests, gradio as gr

# --- simple helpers ---
def openai_chat(prompt: str) -> str:
    key = os.environ.get("OPENAI_API_KEY")
    if not key: 
        return "Missing OPENAI_API_KEY (add it in your Space Secrets)."
    url = "https://api.openai.com/v1/chat/completions"
    data = {"model": os.environ.get("OPENAI_MODEL","gpt-4o-mini"),
            "messages":[{"role":"user","content":prompt}],
            "temperature":0.7}
    r = requests.post(url, json=data, headers={"Authorization":f"Bearer {key}"})
    try:
        return r.json()["choices"][0]["message"]["content"].strip()
    except Exception:
        return f"OpenAI error: {r.status_code} {r.text}"

def anthropic_chat(prompt: str) -> str:
    key = os.environ.get("ANTHROPIC_API_KEY")
    if not key:
        return "Missing ANTHROPIC_API_KEY."
    url = "https://api.anthropic.com/v1/messages"
    data = {
        "model": os.environ.get("ANTHROPIC_MODEL","claude-3-5-sonnet-latest"),
        "max_tokens": 512,
        "messages":[{"role":"user","content":prompt}]
    }
    headers = {
        "x-api-key": key,
        "anthropic-version": "2023-06-01",
        "content-type":"application/json"
    }
    r = requests.post(url, json=data, headers=headers)
    try:
        return "".join([b.get("text","") for b in r.json()["content"]]).strip()
    except Exception:
        return f"Anthropic error: {r.status_code} {r.text}"

def deepseek_chat(prompt: str) -> str:
    key = os.environ.get("DEEPSEEK_API_KEY")
    if not key:
        return "Missing DEEPSEEK_API_KEY."
    url = "https://api.deepseek.com/chat/completions"
    data = {"model": os.environ.get("DEEPSEEK_MODEL","deepseek-chat"),
            "messages":[{"role":"user","content":prompt}],
            "temperature":0.7}
    r = requests.post(url, json=data, headers={"Authorization":f"Bearer {key}"})
    try:
        return r.json()["choices"][0]["message"]["content"].strip()
    except Exception:
        return f"DeepSeek error: {r.status_code} {r.text}"

# Orchestrator: try OpenAI → Anthropic → DeepSeek (whichever has a key)
def smart_route(prompt: str) -> str:
    if os.environ.get("OPENAI_API_KEY"): 
        out = openai_chat(prompt)
        if not out.lower().startswith(("openai error","missing")):
            return out
    if os.environ.get("ANTHROPIC_API_KEY"):
        out = anthropic_chat(prompt)
        if not out.lower().startswith(("anthropic error","missing")):
            return out
    if os.environ.get("DEEPSEEK_API_KEY"):
        out = deepseek_chat(prompt)
        if not out.lower().startswith(("deepseek error","missing")):
            return out
    return "No working API key found. Add at least one provider key in Space Secrets."

# --- Gradio UI ---
def ui_answer(prompt):
    return smart_route(prompt)

with gr.Blocks(title="Bestie AI Hub") as demo:
    gr.Markdown("## 🐼 Bestie AI Hub — Mobile Multi-Model Orchestration")
    inp = gr.Textbox(label="Ask me anything", placeholder="Type your prompt…")
    out = gr.Markdown(label="Answer")
    btn = gr.Button("Send")
    btn.click(ui_answer, inp, out)
    inp.submit(ui_answer, inp, out)

if __name__ == "__main__":
    demo.launch()
