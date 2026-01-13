from __future__ import print_function

import numpy as np
import cv2
import os
import sys
import traceback

try:
    import tensorflow as tf
    try:
        import tf_keras
        from tf_keras.models import model_from_json
        print("[INFO] Using tf_keras for legacy model loading.")
    except ImportError:
        from tensorflow.keras.models import model_from_json
        print("[INFO] Using standard tensorflow.keras for model loading.")
    TENSORFLOW_AVAILABLE = True
except ImportError as e:
    print(f"[ERROR] TensorFlow/Keras could not be loaded: {e}")
    TENSORFLOW_AVAILABLE = False


class Flower:
    def __init__(self, name, areas):
        self.name = name
        self.areas = areas

# Global cache for loaded models
LOADED_MODELS = []
MODELS_INITIALIZED = False

def load_model_robust(model_path, weight_path):
    """Hàm load model từ file JSON và weight với xử lý lỗi"""
    try:
        if not os.path.exists(model_path):
            print(f"[ERROR] Model JSON file not found: {model_path}")
            return None
        if not os.path.exists(weight_path):
            print(f"[ERROR] Model weights file not found: {weight_path}")
            return None

        # Try loading .h5 directly first (more reliable in newer Keras)
        if weight_path.endswith('.h5'):
            try:
                print(f"[INFO] Attempting direct .h5 load: {os.path.basename(weight_path)}")
                # Try standard load_model if available
                if 'tf_keras' in sys.modules:
                    import tf_keras
                    model = tf_keras.models.load_model(weight_path)
                    print(f"[INFO] Successfully loaded model from .h5 using tf_keras: {os.path.basename(weight_path)}")
                else:
                    model = tf.keras.models.load_model(weight_path)
                    print(f"[INFO] Successfully loaded model from .h5 using tensorflow.keras: {os.path.basename(weight_path)}")
                return model
            except Exception as e:
                print(f"[INFO] Direct .h5 load failed ({type(e).__name__}: {str(e)}), trying JSON+Weights method...")

        # Fallback: Load from JSON + weights
        print(f"[INFO] Attempting JSON+Weights load: {os.path.basename(model_path)}")
        with open(model_path, 'r', encoding='utf-8') as json_file:
            loaded_model_json = json_file.read()
        
        # Try loading with model_from_json (which might be from tf_keras)
        try:
            if 'tf_keras' in sys.modules:
                import tf_keras
                model = tf_keras.models.model_from_json(loaded_model_json)
            else:
                model = model_from_json(loaded_model_json)
        except Exception as e:
            print(f"[ERROR] model_from_json failed ({type(e).__name__}): {str(e)}")
            traceback.print_exc()
            return None

        try:
            model.load_weights(weight_path)
            print(f"[INFO] Successfully loaded model from JSON+Weights: {os.path.basename(model_path)}")
            return model
        except Exception as e:
            print(f"[ERROR] Failed to load weights ({type(e).__name__}): {str(e)}")
            traceback.print_exc()
            return None
            
    except Exception as e:
        print(f"[ERROR] Unexpected error loading model {model_path}: {type(e).__name__}: {str(e)}")
        traceback.print_exc()
        return None


def init_models():
    global LOADED_MODELS, MODELS_INITIALIZED
    if MODELS_INITIALIZED:
        print(f"[INFO] Models already initialized ({len(LOADED_MODELS)} models loaded).")
        return
        
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    model_configs = [
        (os.path.join(BASE_DIR, "model", "model_inceptionv3.json"),
         os.path.join(BASE_DIR, "model", "model_inceptionv3.h5")),
        (os.path.join(BASE_DIR, "model", "model_mobilenet.json"),
         os.path.join(BASE_DIR, "model", "model_mobilenet.h5")),
        (os.path.join(BASE_DIR, "model", "model_vgg16.json"),
         os.path.join(BASE_DIR, "model", "model_vgg16.h5")),
    ]
    
    print(f"[INFO] Starting to load {len(model_configs)} models...")
    for i, (m_path, w_path) in enumerate(model_configs, 1):
        print(f"[INFO] Loading model {i}/{len(model_configs)}: {os.path.basename(m_path)}")
        if not os.path.exists(m_path):
            print(f"[ERROR] Model JSON not found: {m_path}")
            continue
        if not os.path.exists(w_path):
            print(f"[ERROR] Model weights not found: {w_path}")
            continue
            
        model = load_model_robust(m_path, w_path)
        if model:
            LOADED_MODELS.append(model)
            print(f"[INFO] Successfully loaded model {i}: {os.path.basename(m_path)}")
        else:
            print(f"[ERROR] Failed to load model {i}: {os.path.basename(m_path)}")
            
    MODELS_INITIALIZED = True
    print(f"[INFO] Model initialization complete: {len(LOADED_MODELS)}/{len(model_configs)} models loaded successfully.")
    
    if not LOADED_MODELS:
        print("[WARNING] No models were loaded successfully! Recognition will fail.")
        print("[WARNING] Please check:")
        print("  1. TensorFlow/Keras is installed correctly")
        print("  2. Model files exist in the model directory")
        print("  3. Model files are not corrupted")


def recognitionFlower(pathImage):
    if not TENSORFLOW_AVAILABLE:
        print("[ERROR] Recognition failed: TensorFlow is not available.")
        return [{'name_flower': 'Error: Recognition Unavailable', 'areas': [], 'match_rate': 0}]

    init_models()
    
    if not LOADED_MODELS:
        print("[ERROR] No models loaded. Recognition cannot proceed.")
        return [{'name_flower': 'Error: Models failed to load', 'areas': [], 'match_rate': 0}]

    flowers = [
        Flower('bluebell', ['Tropical Rainforest', 'Temperate']),        
        Flower('carnation', ['Grassland and Meadow', 'Mediterranean ', 'Temperate']),
        Flower('Dahlia', ['Grassland and Meadow', 'Temperate', 'Montane']),
        Flower('Forget-Me-Not', ['Dry Forest and Coastal Areas', 'Subtropical', 'Tropical']), 
        Flower('Frangipani ', ['Dry Forest and Coastal Areas', 'Subtropical', 'Tropical']),   
        Flower('Jasmine', ['Woodland and Shrubland', 'Subtropical', 'Tropical']),
        Flower('Marigold', ['Grassland and Meadow', 'Subtropical', 'Tropical']),
        Flower('Mimosa', ['Woodland and Shrubland', 'Savanna and Grassland', 'Subtropical', 'Tropical']),
        Flower('Orchid', ['Tropical Rainforest', 'Subtropical', 'Montane', 'Grassland and Meadow']),
        Flower('Zinnia', ['Grassland and Meadow', 'Subtropical', 'Temperate']), 
        Flower('astilbe', ['Woodland and Shrubland', 'Temperate ', 'Wetland and Riparian']),
        Flower('bellflower', ['Woodland and Shrubland', 'Alpine and Montane', 'Temperate ', 'Meadow and Grassland']),
        Flower('black_eyed_susan', ['Grassland and Meadow', 'Temperate ', 'Prairie and Open Woodland', 'Roadside and Disturbed Areas']),
        Flower('buttercup', ['Grassland and Meadow']),
        Flower('calendula', ['Grassland and Meadow']),
        Flower('california_poppy', ['Grassland and Meadow', 'Mediterranean', 'Desert and Semi-Arid', 'Coastal Areas']),
        Flower('cherryblossom', ['Woodland and Shrubland', 'Temperate ', 'Montane and Highland']),
        Flower('coltsfoot', ['Grassland and Meadow']),
        Flower('common daisy', ['Grassland and Meadow', 'Temperate', 'Woodland Edge and Shrubland', 'Lawn and Urban Areas']),
        Flower('coreopsis', ['Grassland and Meadow', 'Temperate', 'Prairie and Open Woodland', 'Roadside and Disturbed Areas']),
        Flower('cowslip', ['Grassland and Meadow']),
        Flower('crocus', ['Grassland and Meadow', 'Temperate']),
        Flower('daffodil', ['Temperate', 'Subtropical']),
        Flower('daisy', ['Grassland and Meadow', 'Temperate']),
        Flower('dandelion', ['Grassland and Meadow', 'Temperate']),
        Flower('fritillary', ['Grassland and Meadow']),   
        Flower('iris', ['Temperate', 'Subtropical']),
        Flower('lily', ['Subtropical', 'Temperate']),
        Flower('lilyvalley', ['Subtropical', 'Temperate']),
        Flower('magnolia', ['Woodland and Forest', 'Temperate', 'Subtropical', 'Wetland and Riparian']), # 29
        Flower('pansy', ['Grassland and Meadow', 'Temperate']), # 30
        Flower('rose', ['Grassland and Meadow', 'Temperate']), # 31
        Flower('snowdrop', ['Temperate']), # 32
        Flower('sunflower', ['Desert']), # 33
        Flower('tigerlily', ['Subtropical']), # 34
        Flower('tulip', ['Grassland and Meadow', 'Temperate', 'Subtropical']), # 35
        Flower('water_lily', ['Freshwater Wetlands', 'Tropical and Temperate', 'Slow-moving Rivers and Ponds']), # 36
        Flower('windflower', ['Grassland and Meadow', 'Temperate']), # 37
        Flower('scorpion grasses', ['Grassland and Meadow', 'Wetland and Riparian', 'Temperate ']), # 38
    ]
    
    # Ensure flower list is at least large enough for potential model outputs
    while len(flowers) < 64: 
        flowers.append(Flower('Unknown', ['Unknown']))

    # Đọc ảnh một cách an toàn (handle Vietnamese/special characters in path)
    try:
        img_array = np.fromfile(pathImage, np.uint8)
        img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("Failed to decode image")
    except Exception as e:
        print(f"[ERROR] Could not read image {pathImage}: {e}")
        return [{'name_flower': 'Error: Invalid Image', 'areas': [], 'match_rate': 0}]

    faceAligned = cv2.resize(img, (244, 244), interpolation=cv2.INTER_AREA)
    faceAligned = np.array(faceAligned).astype('float32') / 255.0
    faceAligned = np.expand_dims(faceAligned, axis=0)

    best_predictions = [] 

    for model in LOADED_MODELS:
        try:
            Y_pred = model.predict(faceAligned, verbose=0)
            best_index = np.argmax(Y_pred[0])
            best_confidence = Y_pred[0][best_index]
            
            if best_index < len(flowers):
                best_flower = flowers[best_index]
                if best_confidence >= 0.01:
                    best_predictions.append((best_flower, best_confidence))
        except Exception as e:
            print(f"[WARNING] Prediction failed with model: {e}")

    best_predictions.sort(key=lambda x: x[1], reverse=True)
    top_2_results = best_predictions[:2]

    if not top_2_results:
        return [{'name_flower': 'Flower not recognized', 'areas': [], 'match_rate': 0}]

    return [
        {'name_flower': item[0].name, 'areas': item[0].areas, 'match_rate': int(item[1] * 100)}
        for item in top_2_results
    ]
