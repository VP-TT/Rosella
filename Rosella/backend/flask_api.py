from flask import Flask, request, jsonify
import numpy as np
import pandas as pd
import joblib
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})
# CORS(app, origins=["http://localhost:51900"])


# Load the trained model
model = joblib.load('mlp_model.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    # Extract features from the request (ensure they are of correct type)
    features = np.array(data['features'], dtype=np.float64).reshape(1, -1)
    print(features)
    # Get the prediction
    prediction = model.predict(features)

    # Convert any numpy types to native Python types for JSON serialization
    prediction = prediction.item()  # Converts numpy.int64 to Python int

    return jsonify({'prediction': prediction})

if __name__ == '__main__':
    app.run(debug=True)
