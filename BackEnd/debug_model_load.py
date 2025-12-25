import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # Suppress TF logs
import tensorflow as tf
from tensorflow.keras.models import model_from_json, Sequential, load_model
from tensorflow.keras.layers import InputLayer

print(f"TF: {tf.__version__}")

json_path = r"D:\DATN_DACS\DATN\DATN\BackEnd\feature\recognition\model\model_inceptionv3.json"
h5_path = r"D:\DATN_DACS\DATN\DATN\BackEnd\feature\recognition\model\model_inceptionv3.h5"

print("--- TEST 1: Direct .h5 load ---")
try:
    model = load_model(h5_path)
    print("TEST 1 SUCCESS")
except Exception as e:
    print(f"TEST 1 FAILED: {str(e).splitlines()[0]}") # Print only first line of error

print("\n--- TEST 2: JSON load ---")
try:
    with open(json_path, 'r') as f:
        json_str = f.read()
    
    custom_objects = {'Sequential': Sequential, 'InputLayer': InputLayer}
    
    try:
        model = model_from_json(json_str, custom_objects=custom_objects)
        print("TEST 2 JSON LOAD SUCCESS")
        model.load_weights(h5_path)
        print("TEST 2 WEIGHTS LOAD SUCCESS")
    except Exception as e:
        err = str(e)
        # If error is long (like config dump), truncate it
        if len(err) > 500:
            err = err[:200] + " ... " + err[-200:]
        print(f"TEST 2 FAILED: {err}")

except Exception as e:
    print(f"TEST 2 SETUP FAILED: {e}")
