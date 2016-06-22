# -*- encoding: utf-8 -*-
# Author: Epix
import os
import uuid

from flask import Flask, send_from_directory, request, jsonify

from make_morph import make_morphs, readPoints

app = Flask(__name__)
UPLOAD_PATH = 'upload'
GEN_PATH = 'generated'


@app.route('/upload', methods=['POST'])
def upload():
    upload_files = request.files.values()
    output_filename = os.path.join(UPLOAD_PATH, uuid.uuid4().hex + '.jpg')
    list(upload_files)[0].save(output_filename)
    return output_filename.replace('\\', '/')


@app.route('/generated/<path:path>', methods=['GET'])
def get_generated(path):
    return send_from_directory('generated', path)


@app.route('/upload/<path:path>', methods=['GET'])
def get_upload(path):
    return send_from_directory('upload', path)


@app.route('/morph', methods=['POST'])
def get_morph():
    j = request.json
    prefix = os.path.join(GEN_PATH, uuid.uuid4().hex)
    points1 = readPoints('a.txt')
    points2 = readPoints('b.txt')
    r = make_morphs(j['pictures'][0], j['pictures'][1], prefix, points1, points2)
    # r = make_morphs(j['pictures'][0], j['pictures'][1], prefix, j['points1'], j['points2'])
    return jsonify({'result': r})


@app.route('/', methods=['GET'])
def homepage():
    return send_from_directory('static', 'index.html')


@app.route('/<path:path>')
def send_static(path):
    return send_from_directory('static', path)


if __name__ == '__main__':
    app.run(
        # debug=True
    )
