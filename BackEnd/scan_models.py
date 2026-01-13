import os
import sys
import google.generativeai as genai
from dotenv import load_dotenv
import time

load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    print("Error: GEMINI_API_KEY not found")
    sys.exit(1)

genai.configure(api_key=api_key)

def scan_all_models():
    print(f"Scanning with Key: {api_key[:5]}...{api_key[-5:]}")
    try:
        models = genai.list_models()
        for m in models:
            if 'generateContent' in m.supported_generation_methods:
                model_name = m.name
                print(f"\n--- Testing {model_name} ---")
                try:
                    model_instance = genai.GenerativeModel(model_name)
                    response = model_instance.generate_content("Hi", generation_config={"max_output_tokens": 10})
                    if response.text:
                        print(f"!!! SUCCESS with {model_name} !!!")
                        print(f"Reply: {response.text}")
                        return model_name
                except Exception as e:
                    # Print only the first line of error to keep it clean
                    error_first_line = str(e).split('\n')[0]
                    print(f"Failed: {error_first_line}")
                time.sleep(0.5)
    except Exception as e:
        print(f"Error listing models: {e}")
    return None

if __name__ == "__main__":
    scan_all_models()
