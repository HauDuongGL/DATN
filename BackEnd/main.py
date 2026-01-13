import os
import sys

# Force legacy Keras for compatibility with old models
os.environ['TF_USE_LEGACY_KERAS'] = '1'

# Add DLL directory for TensorFlow
if os.name == 'nt':
    dll_dir = r"C:\Program Files\Common Files\microsoft shared\ClickToRun"
    if os.path.exists(dll_dir):
        os.add_dll_directory(dll_dir)

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename

from feature.description import callGpt
from feature.description import callGemini
from feature.description import callGroq
from model.Flower import Flower
from feature.recognition.recognitionFlower import recognitionFlower

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(BASE_DIR, "feature", "recognition", "imageReceive")
os.makedirs(UPLOAD_DIR, exist_ok=True)

app = Flask(__name__)
# Enable CORS with more permissive settings for mobile apps
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "ngrok-skip-browser-warning"]
    }
})


# Pre-load models at startup
from feature.recognition.recognitionFlower import init_models
print("[BE] Pre-loading AI models...", flush=True)
init_models()
print("[BE] Models loaded successfully.", flush=True)

@app.route('/recognition', methods=['POST', 'GET', 'OPTIONS'])
def recognition():
    print(f"[BE] Received /recognition request: {request.method}", flush=True)
    print(f"[BE] Headers: {dict(request.headers)}", flush=True)
    print(f"[BE] Content-Type: {request.content_type}", flush=True)
    
    if request.method == 'OPTIONS':
        # Handle preflight request
        response = jsonify({'status': 'ok'})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type, ngrok-skip-browser-warning')
        response.headers.add('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        return response, 200
    
    if request.method == 'POST':
        print(f"[BE] Files in request: {list(request.files.keys())}", flush=True)
        print(f"[BE] Form data: {dict(request.form)}", flush=True)
        
        if 'file' not in request.files:
            print("[BE] ERROR: No 'file' key in request.files", flush=True)
            return jsonify({
                'status': 'error',
                'message': 'No file part in the request'
            }), 400

        file = request.files['file']
        if file.filename == '':
            print("[BE] ERROR: Empty filename", flush=True)
            return jsonify({
                'status': 'error',
                'message': 'Empty filename'
            }), 400

        filename = secure_filename(file.filename)
        file_path = os.path.join(UPLOAD_DIR, filename)
        file.save(file_path)
        print(f"[BE] /recognition received: {filename} -> {file_path}", flush=True)

        try:
            flowers = recognitionFlower(file_path)
            print(f"[BE] Recognition result: {len(flowers)} flowers found", flush=True)

            response = {
                'status': 'success',
                'message': 'File uploaded successfully',
                'results': flowers
            }

            return jsonify(response), 200
        except Exception as e:
            print(f"[BE] ERROR in recognition: {str(e)}", flush=True)
            import traceback
            traceback.print_exc()
            return jsonify({
                'status': 'error',
                'message': f'Recognition failed: {str(e)}'
            }), 500
    else:
        response = {
            'status': 'error',
            'message': 'No file uploaded'
        }
        return jsonify(response), 400


@app.route('/description/<nameFlower>', methods=['GET'])
def descriptionFlower(nameFlower):
    if request.method == 'GET':
        flower = Flower(
            nameFlower,
            callGpt.callGPT("Description " + nameFlower + "limited to 100 words" + "remove headline "),
            callGpt.callGPT("List species " + nameFlower + "limited to 100 words" + "remove headline "),
            callGpt.callGPT("How to care " + nameFlower + "limited to 100 words" + "remove headline "),
        )
        response = {
            'status': 'success',
            'message': 'Description ' + nameFlower,
            'flower': flower.__dict__
        }

        return jsonify(response), 200
    else:
        response = {
            'status': 'error',
            'message': "Server can't get name flower"
        }
        return jsonify(response), 400


@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.get_json(silent=True) or {}
        messages = data.get('messages')
        system = data.get('system')
        model = data.get('model', 'gpt-4o-mini')
        
        with open("chat_debug.log", "a", encoding="utf-8") as f:
            f.write(f"\n--- Request at {request.remote_addr} ---\n")
            f.write(f"Model: {model}\n")
            f.write(f"Messages count: {len(messages) if isinstance(messages, list) else 'N/A'}\n")
            f.write(f"Payload: {data}\n")
        
        print(f"DEBUG: Received chat request. Model: {model}", flush=True)

        if not isinstance(messages, list) or not messages:
            print("DEBUG: Invalid messages payload", flush=True)
            return jsonify({
                'status': 'error',
                'message': 'Invalid payload: messages (list) is required'
            }), 400

        # Determine which AI provider to use based on model name
        if model.startswith('gemini'):
            # Use Gemini
            reply = callGemini.chat(messages=messages, system=system, model=model, stream=False)
        elif model.startswith('llama') or model.startswith('mixtral') or model.startswith('gemma'):
            # Use Groq
            reply = callGroq.chat(messages=messages, system=system, model=model, stream=False)
        else:
            # Use OpenAI GPT (default)
            reply = callGpt.chat(messages=messages, system=system, model=model, stream=False)
        
        if reply is None:
            return jsonify({'status': 'error', 'message': 'Chat generation failed'}), 500

        return jsonify({
            'status': 'success',
            'message': 'ok',
            'reply': reply
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=False, threaded=True)

