from openai import OpenAI
import os
from dotenv import load_dotenv

# Retrieve API key from environment variables
# api_key = os.getenv("OPENAI_API_KEY")
# if not api_key:
#     raise ValueError("Missing API key. Set the OPENAI_API_KEY environment variable.")
api_key = os.getenv("OPENAI_API_KEY")
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
