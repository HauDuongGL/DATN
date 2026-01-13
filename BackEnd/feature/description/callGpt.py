from openai import OpenAI
import os
from dotenv import load_dotenv, find_dotenv

env_path = find_dotenv(filename=".env", usecwd=True)
if env_path:
    load_dotenv(env_path, override=True)

# Accept both OPENAI_API_KEY (preferred) and OPEN_API_KEY (fallback)
def get_api_key():
    # Thử tìm .env trong thư mục Backend
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
    
    key = os.getenv("OPENAI_API_KEY") or os.getenv("OPEN_API_KEY")
    return key

def get_client():
    key = get_api_key()
    if not key:
        return None
    return OpenAI(api_key=key)

def callGPT(prompt):
    """
    Calls OpenAI's GPT model and streams the response.
    """
    client = get_client()
    if not client:
        print("Error: OpenAI API key is missing.")
        return "Error: OpenAI API key is missing. Please check your .env file."
        
    try:
        stream = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            stream=True,
        )
        response = ""

        for chunk in stream:
            if chunk.choices and chunk.choices[0].delta.content:
                text = chunk.choices[0].delta.content
                response += text
                print(text, end="") 

        return response

    except Exception as e:
        print(f"Error: {e}")
        return None


def chat(messages, model: str = "gpt-4o-mini", system: str | None = None, stream: bool = False):
    """
    Generic chat completion helper.

    messages: list of dicts with keys: role ("system"|"user"|"assistant"), content (str)
    If system is provided, it will be prepended as a system message.
    Returns a single string reply when stream = False.
    """
    client = get_client()
    if not client:
        print("Error: OpenAI API key is missing.")
        return None

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
            # For now, keep non-stream to simplify; could be extended to yield SSE
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
        print(f"Error: {e}")
        return None

# if __name__ == '__main__':
#     print(callGPT("Describe a tulip"))
