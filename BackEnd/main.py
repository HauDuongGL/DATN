import os

from flask import Flask, request, jsonify

from feature.description import callGpt
from model.Flower import Flower
from feature.recognition.recognitionFlower import recognitionFlower

app = Flask(__name__)


@app.route('/recognition', methods=['POST', 'GET'])
def recognition():
    if request.method == 'POST':
        file = request.files['file']
        file_path = os.path.join(r'D:\DATN_DACS\FlowerIdentifier\BackEnd\feature\recognition\imageReceive', file.filename)
        file.save(file_path)

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


if __name__ == '__main__':
    app.run(host="192.168.1.161")

