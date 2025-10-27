import os
import requests

# Simple multi-model AI hub starter (v0.1)
# Will expand step-by-step — do NOT modify anything yet.

def ask_model(prompt, api_key, endpoint):
    """Basic request example — we will upgrade this soon."""
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    data = {"model": "gpt-4o-mini", "messages": [{"role": "user", "content": prompt}]}
    response = requests.post(endpoint, json=data, headers=headers)
    return response.json()

if __name__ == "__main__":
    print("✅ Bestie AI Hub initialized.")
    print("Next step: We plug in real API keys + routing logic together.")
