from __future__ import print_function

import numpy as np
import cv2
from keras.models import model_from_json


class Flower:
    def __init__(self, name, areas):
        self.name = name
        self.areas = areas

def load_model(model_path, weight_path):
    """Hàm load model từ file JSON và weight"""
    json_file = open(model_path, 'r')
    loaded_model_json = json_file.read()
    json_file.close()
    model = model_from_json(loaded_model_json)
    model.load_weights(weight_path)
    return model


def recognitionFlower(pathImage):

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
        Flower('magnolia', ['Woodland and Forest', 'Temperate', 'Subtropical', 'Wetland and Riparian']),
        Flower('pansy', ['Grassland and Meadow', 'Temperate']),
        Flower('rose', ['Grassland and Meadow', 'Temperate']),
        Flower('snowdrop', ['Temperate']),
        Flower('sunflower', ['Desert']),
        Flower('tigerlily', ['Subtropical']),
        Flower('tulip', ['Grassland and Meadow', 'Temperate', 'Subtropical']),
        Flower('water_lily', ['Freshwater Wetlands', 'Tropical and Temperate', 'Slow-moving Rivers and Ponds']),
        Flower('windflower', ['Grassland and Meadow', 'Temperate']),
        Flower('scorpion grasses', ['Grassland and Meadow', 'Wetland and Riparian', 'Temperate ']),
    ]  

    model_paths = [
        (r"D:\DATN_DACS\FlowerIdentifier\BackEnd\feature\recognition\model\model_inceptionv3.json",
         r"D:\DATN_DACS\FlowerIdentifier\BackEnd\feature\recognition\model\model_inceptionv3.h5"),
        (r"D:\DATN_DACS\FlowerIdentifier\BackEnd\feature\recognition\model\model_mobilenet.json",
         r"D:\DATN_DACS\FlowerIdentifier\BackEnd\feature\recognition\model\model_mobilenet.h5"),
        (r"D:\DATN_DACS\FlowerIdentifier\BackEnd\feature\recognition\model\model_vgg16.json",
         r"D:\DATN_DACS\FlowerIdentifier\BackEnd\feature\recognition\model\model_vgg16.h5"),
    ]

    # Đọc ảnh và tiền xử lý
    img = cv2.imread(pathImage)
    faceAligned = cv2.resize(img, (244, 244), interpolation=cv2.INTER_AREA)
    faceAligned = np.array(faceAligned).astype('float32') / 255.0
    faceAligned = np.expand_dims(faceAligned, axis=0)

    best_predictions = []  # Danh sách chứa kết quả tốt nhất từ từng model

    # Dự đoán với từng model
    for model_path, weight_path in model_paths:
        model = load_model(model_path, weight_path)
        Y_pred = model.predict(faceAligned)

        # Lấy kết quả có độ khớp cao nhất trong model này
        best_index = np.argmax(Y_pred[0])  # Lấy index của kết quả có confidence cao nhất
        best_confidence = Y_pred[0][best_index]  # Lấy độ chính xác
        best_flower = flowers[best_index]  # Lấy loài hoa tương ứng

        if best_confidence >= 0.01:  # Chỉ lưu nếu độ chính xác > 1%
            best_predictions.append((best_flower, best_confidence))

    # Sắp xếp kết quả theo độ chính xác giảm dần
    best_predictions.sort(key=lambda x: x[1], reverse=True)

    # Lấy 2 kết quả tốt nhất từ 2 model khác nhau
    top_2_results = best_predictions[:2]

    # Trả về kết quả
    return [
        {'name_flower': item[0].name, 'areas': item[0].areas, 'match_rate': int(item[1] * 100)}
        for item in top_2_results
    ]