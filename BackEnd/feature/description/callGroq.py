from openai import OpenAI
import os
from dotenv import load_dotenv, find_dotenv

env_path = find_dotenv(filename=".env", usecwd=True)
if env_path:
    load_dotenv(env_path, override=True)

def get_api_key():
    current_file = os.path.abspath(__file__)
    current_dir = os.path.dirname(current_file)
    backend_dir = os.path.dirname(os.path.dirname(current_dir))
    env_path = os.path.join(backend_dir, ".env")
    
    if os.path.exists(env_path):
        load_dotenv(env_path, override=True)
    else:
        # Fallback to default search
        env_path = find_dotenv(filename=".env", usecwd=True)
        if env_path:
            load_dotenv(env_path, override=True)
    
    key = os.getenv("GROQ_API_KEY")
    return key

def get_client():
    key = get_api_key()
    if not key:
        return None
    return OpenAI(
        api_key=key,
        base_url="https://api.groq.com/openai/v1"
    )

def chat(messages, model: str = "llama-3.3-70b-versatile", system: str | None = None, stream: bool = False):
    """
    Generic chat completion helper for Groq.
    """
    client = get_client()
    if not client:
        print("Error: Groq API key is missing.")
        return "Error: Groq API key is missing. Please check your .env file."

    try:
        msgs = []
        if system:
            msgs.append({"role": "system", "content": system})

        # Sanitize and only keep needed keys
        for m in messages or []:
            role = m.get("role")
            content = m.get("content")
            if role in ("user", "assistant", "system") and isinstance(content, str) and content.strip():
                msgs.append({"role": role, "content": content})

        if not msgs:
            raise ValueError("No valid messages provided")

        if stream:
            # For now, keep non-stream to simplify
            stream_resp = client.chat.completions.create(
                model=model,
                messages=msgs,
                stream=True,
            )
            text = ""
            for chunk in stream_resp:
                if chunk.choices and chunk.choices[0].delta.content:
                    piece = chunk.choices[0].delta.content
                    text += piece
                    print(piece, end="")
            return text
        else:
            resp = client.chat.completions.create(
                model=model,
                messages=msgs,
                stream=False,
            )
            if resp.choices:
                content = resp.choices[0].message.content
                return content or ""
            return ""
    except Exception as e:
        error_msg = str(e)
        print(f"Groq Error: {error_msg}")
        return f"Groq Error: {error_msg}"
