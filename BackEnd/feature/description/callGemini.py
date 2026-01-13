import google.generativeai as genai
import os
from dotenv import load_dotenv, find_dotenv

env_path = find_dotenv(filename=".env", usecwd=True)
if env_path:
    load_dotenv(env_path, override=True)

# Get Gemini API key from environment
def get_api_key():
    # Thử tìm .env trong thư mục Backend
    current_dir = os.path.dirname(os.path.abspath(__file__))
    backend_dir = os.path.dirname(os.path.dirname(current_dir))
    env_path = os.path.join(backend_dir, ".env")
    
    if os.path.exists(env_path):
        load_dotenv(env_path, override=True)
    else:
        env_path = find_dotenv(filename=".env", usecwd=True)
        if env_path:
            load_dotenv(env_path, override=True)
            
    return os.getenv("GEMINI_API_KEY")

def configure_genai():
    api_key = get_api_key()
    if api_key:
        genai.configure(api_key=api_key)
        return True
    return False

def chat(messages, model: str = "gemini-2.0-flash", system: str | None = None, stream: bool = False):
    """
    Generic chat completion helper for Google Gemini.
    
    messages: list of dicts with keys: role ("system"|"user"|"assistant"), content (str)
    If system is provided, it will be prepended as a system message.
    Returns a single string reply when stream = False.
    """
    if not configure_genai():
        print("Gemini Error: API key is missing.")
        return "Gemini Error: API key is missing. Please check your .env file."

    try:
        # Convert messages format for Gemini
        # Gemini uses different message format than OpenAI
        chat_history = []
        last_user_message = None
        
        # Convert messages to Gemini format
        for m in messages or []:
            role = m.get("role")
            content = m.get("content")
            if role in ("user", "assistant", "system") and isinstance(content, str) and content.strip():
                if role == "system":
                    # System messages in Gemini are handled via system_instruction
                    continue
                elif role == "user":
                    # Store user messages for history
                    chat_history.append({"role": "user", "parts": [content]})
                    last_user_message = content
                elif role == "assistant":
                    # Store assistant responses for history
                    chat_history.append({"role": "model", "parts": [content]})
        
        if not last_user_message:
            raise ValueError("No valid user message provided")
        
        # Initialize the model with system instruction if provided
        generation_config = {}
        if system:
            model_instance = genai.GenerativeModel(
                model_name=model,
                system_instruction=system
            )
        else:
            model_instance = genai.GenerativeModel(model_name=model)
        
        # Start a chat session with history (excluding the last user message)
        history_for_session = chat_history[:-1] if len(chat_history) > 1 and chat_history[-1].get("role") == "user" else chat_history[:-2] if len(chat_history) > 2 else []
        chat_session = model_instance.start_chat(history=history_for_session)
        
        if stream:
            # Stream response
            response = chat_session.send_message(last_user_message, stream=True)
            text = ""
            for chunk in response:
                if chunk.text:
                    text += chunk.text
                    print(chunk.text, end="")
            return text
        else:
            # Non-stream response
            response = chat_session.send_message(last_user_message)
            return response.text or ""
            
    except Exception as e:
        error_msg = str(e)
        print(f"Gemini Error: {error_msg}")
        
        # Fallback logic: if the specific model is not found, try the default "gemini-2.0-flash"
        if "404" in error_msg and model != "gemini-2.0-flash":
            print(f"Retrying with fallback model: gemini-2.0-flash")
            return chat(messages, model="gemini-2.0-flash", system=system, stream=stream)
            
        import traceback
        traceback.print_exc()
        return f"Gemini Error: {error_msg}"
