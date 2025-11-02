from openai import OpenAI
import os
from dotenv import load_dotenv, find_dotenv


env_path = find_dotenv(filename=".env", usecwd=True)
if env_path:
    load_dotenv(env_path, override=True)

# Accept both OPENAI_API_KEY (preferred) and OPEN_API_KEY (fallback)
api_key = os.getenv("OPENAI_API_KEY") or os.getenv("OPEN_API_KEY")
if not api_key:
    raise ValueError(
        "Missing API key. Set OPENAI_API_KEY (preferred) or OPEN_API_KEY via environment or .env"
    )

client = OpenAI(api_key=api_key)

def callGPT(prompt):
    """
    Calls OpenAI's GPT model and streams the response.
    """
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

# if __name__ == '__main__':
#     print(callGPT("Describe a tulip"))
