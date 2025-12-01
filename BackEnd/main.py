import os

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename

from feature.description import callGpt
from model.Flower import Flower
from feature.recognition.recognitionFlower import recognitionFlower

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(BASE_DIR, "feature", "recognition", "imageReceive")
os.makedirs(UPLOAD_DIR, exist_ok=True)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes


@app.route('/recognition', methods=['POST', 'GET'])
def recognition():
    if request.method == 'POST':
        if 'file' not in request.files:
            return jsonify({
                'status': 'error',
                'message': 'No file part in the request'
            }), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({
                'status': 'error',
                'message': 'Empty filename'
            }), 400

        filename = secure_filename(file.filename)
        file_path = os.path.join(UPLOAD_DIR, filename)
        file.save(file_path)
        print(f"[BE] /recognition received: {filename} -> {file_path}", flush=True)

        flowers = recognitionFlower(file_path)

        response = {
            'status': 'success',
            'message': 'File uploaded successfully',
            'results': flowers
        }

        return jsonify(response), 200
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

        if not isinstance(messages, list) or not messages:
            return jsonify({
                'status': 'error',
                'message': 'Invalid payload: messages (list) is required'
            }), 400

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
    app.run(host="0.0.0.0", port=5000, debug=True)

