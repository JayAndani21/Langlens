from flask import Flask, request, jsonify
from paddleocr import PaddleOCR
import cv2
import numpy as np

app = Flask(__name__)
ocr = PaddleOCR(lang="en", use_angle_cls=True)  # Combine languages with underscores  # Add multiple languages

@app.route('/ocr', methods=['POST'])
def process_image():
    try:
        if 'image' not in request.files:
            return jsonify({"error": "No image provided"}), 400
            
        file = request.files['image']
        if file.filename == '':
            return jsonify({"error": "Empty filename"}), 400

        # Read image
        img_bytes = file.read()
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        # Perform OCR
        result = ocr.ocr(img, cls=True)
        
        # Extract text with bounding boxes
        texts = []
        boxes = []
        for line in result:
            for word_info in line:
                texts.append(word_info[1][0])
                boxes.append([list(map(int, point)) for point in word_info[0]])
        
        return jsonify({
            "success": True,
            "text": "\n".join(texts),
            "boxes": boxes,
            "raw": result
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)