from flask import Flask, request, jsonify, render_template, redirect, url_for
import pickle
import numpy as np
from datetime import datetime
import uuid


app = Flask(__name__)


# Load the trained model using pickle
with open('model.pkl', 'rb') as model_file:
    model = pickle.load(model_file)


# Global dictionary to store results temporarily
results_store = {}


fixed_request_id = 'request_id'


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get input data from the form
        engine_rpm = int(request.form['Engine_RPM'])
        oil_pressure = int(request.form['Oil_Pressure'])
        fuel_pressure = int(request.form['Fuel_Pressure'])
        coolant_pressure = int(request.form['Coolant_Pressure'])
        oil_temperature = int(request.form['Oil_Temperature'])
        coolant_temperature = int(request.form['Coolant_Temperature'])


        # Prepare the input for the model
        input_data = np.array([[engine_rpm, oil_pressure, fuel_pressure, coolant_pressure, oil_temperature, coolant_temperature]])


        # Predict engine health status
        prediction = model.predict(input_data)
        engine_health_status = int(prediction[0])


        # Create a unique vehicle ID using UUID
        vehicle_id = uuid.uuid4().int % 10**8


        # Get the current timestamp in YYYYMMDDHHMM format
        timestamp = int(datetime.now().strftime("%Y%m%d%H%M"))


        # Store the data in the global dictionary
        results_store[fixed_request_id] = {
            "VEHICLEID": vehicle_id,
            "ENGINEHEALTH": engine_health_status,
            "TIMESTAMP": timestamp
        }


        # Redirect to the result page
        return redirect(url_for('result'))


    except (TypeError, ValueError):
        return jsonify({"error": "Invalid input, please ensure all parameters are provided and valid integers."}), 400


@app.route('/result', methods=['GET'])
def result():
    # Get the response data from the global dictionary
    response_data = results_store.get(fixed_request_id)


    if response_data is None:
        return jsonify({"error": "No data available for the fixed request ID."}), 400


    # Return the result as JSON
    return jsonify({"data": response_data})


if __name__ == '__main__':
    app.run(debug=True)