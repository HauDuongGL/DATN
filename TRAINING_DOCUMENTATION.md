# Tài Liệu Quy Trình Training Model Nhận Diện Hoa

## 📋 Mục Lục
1. [Tổng Quan](#tổng-quan)
2. [Môi Trường Training](#môi-trường-training)
3. [Dataset](#dataset)
4. [Quy Trình Training Chi Tiết](#quy-trình-training-chi-tiết)
5. [Kiến Trúc Models](#kiến-trúc-models)
6. [Data Augmentation](#data-augmentation)
7. [Đánh Giá và So Sánh Models](#đánh-giá-và-so-sánh-models)
8. [Testing và Inference](#testing-và-inference)
9. [Kết Quả và Lưu Trữ](#kết-quả-và-lưu-trữ)

---

## 🎯 Tổng Quan

Dự án training model nhận diện hoa sử dụng **Transfer Learning** với 3 kiến trúc Deep Learning phổ biến:
- **InceptionV3** (Google)
- **MobileNet** (Google)
- **VGG16** (Oxford)

**Phương pháp**: Ensemble Learning - kết hợp predictions từ 3 models để tăng độ chính xác.

**Dataset**: 29 loài hoa khác nhau

**Môi trường**: Google Colab với GPU T4

---

## 🖥️ Môi Trường Training

### Platform
- **Google Colab** với GPU T4
- **Python 3.12**
- **TensorFlow/Keras** với tf_keras

### Libraries Chính

```python
# Deep Learning
import tensorflow as tf
from tf_keras.applications.vgg16 import VGG16
from tf_keras.applications import InceptionV3
from tf_keras.applications.mobilenet import MobileNet
from tf_keras.utils import to_categorical
import tf_keras.callbacks

# Computer Vision
import cv2
import numpy as np
from PIL import Image

# Data Processing
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score, precision_score, recall_score, f1_score
from sklearn.utils import shuffle

# Utilities
import pandas as pd
import os
from google.colab import drive
```

### Cài Đặt

```python
# Upgrade Keras (nếu cần)
!pip install --upgrade keras

# Mount Google Drive để truy cập dataset
from google.colab import drive
drive.mount('/content/drive')
```

---

## 📁 Dataset

### Cấu Trúc Dataset

```
Dataset Flower/
└── Dataset_29_flowers/
    ├── Carnation/
    │   ├── image1.jpg
    │   ├── image2.jpg
    │   └── ...
    ├── Dahlia/
    ├── Forget-Me-Not/
    ├── Frangipani/
    ├── Jasmine/
    ├── Marigold/
    ├── Mimosa/
    ├── Orchid/
    ├── Zinnia/
    ├── astilbe/
    ├── bellflower/
    ├── black_eyed_susan/
    ├── bluebell/
    ├── buttercup/
    ├── calendula/
    ├── california_poppy/
    ├── cherryblossom/
    ├── coltsfoot/
    ├── common_daisy/
    ├── coreopsis/
    ├── cowslip/
    ├── crocus/
    ├── daffodil/
    ├── daisy/
    ├── dandelion/
    ├── fritillary/
    ├── iris/
    ├── lily/
    ├── lilyvalley/
    ├── magnolia/
    ├── pansy/
    ├── rose/
    ├── snowdrop/
    ├── sunflower/
    ├── tigerlily/
    ├── tulip/
    ├── water_lily/
    └── windflower/
```

**Tổng số classes**: 29 loài hoa

---

## 🔄 Quy Trình Training Chi Tiết

### Bước 1: Load và Preprocessing Dữ Liệu

#### 1.1. Load Images từ Google Drive

```python
labels = []
img_list = []

def cropFlower():
    list_flowers = ""
    root = "/content/drive/MyDrive/Dataset Flower/Dataset_29_flowers"

    if not os.path.exists(root):
        print(f"Lỗi: Thư mục không tồn tại - {root}")
        return

    for index, flower in enumerate(sorted(os.listdir(root))):
        path_flower = os.path.join(root, flower)
        print(f"Đang xử lý: {flower}")
        list_flowers += "{},".format(flower)

        for img in os.listdir(path_flower):
            path_img = os.path.join(path_flower, img)

            # Kiểm tra file hợp lệ
            if not os.path.isfile(path_img):
                print(f" Bỏ qua (không phải file): {path_img}")
                continue

            # Đọc ảnh
            read_img = cv2.imread(path_img)
            if read_img is None:
                print(f" Không thể đọc ảnh: {path_img}")
                continue  # Bỏ qua ảnh lỗi

            # Resize về 244x244 (chuẩn cho các models)
            flower_resized = cv2.resize(
                read_img, 
                (244, 244), 
                interpolation=cv2.INTER_AREA
            )
            labels.append(index)
            img_list.append(flower_resized)

def getImgList():
    if len(img_list) <= 0:
        cropFlower()
    return img_list, labels
```

**Đặc điểm**:
- Tự động detect và skip các file không hợp lệ
- Resize tất cả ảnh về kích thước chuẩn 244x244
- Gán label tự động dựa trên thứ tự thư mục

#### 1.2. Chuẩn Hóa Dữ Liệu

```python
# Load dữ liệu
img_data, labels = getImgList()
num_classes = len(set(labels))

# Convert sang numpy array
img_data = np.array(img_data, dtype='float32')
labels = np.array(labels, dtype='int64')

# Normalize pixel values về [0, 1]
img_data /= 255.0
```

**Preprocessing Steps**:
1. Convert list → numpy array
2. Normalize pixel values từ [0, 255] → [0, 1]
3. Xác định số lượng classes

#### 1.3. Chia Dataset

```python
# Convert labels sang one-hot encoding
Y = to_categorical(labels, num_classes)

# Split train/test với tỷ lệ 80/20
X_train, X_test, y_train, y_test = train_test_split(
    img_data, 
    Y, 
    test_size=0.2, 
    random_state=2  # Fixed seed để reproduce
)

# Xác định input shape
input_shape = X_train[0].shape  # (244, 244, 3)
```

**Train/Test Split**:
- **Training**: 80% dữ liệu
- **Testing**: 20% dữ liệu
- **Random seed**: 2 (đảm bảo reproducibility)

---

### Bước 2: Định Nghĩa Hàm Training

```python
from sklearn.metrics import precision_score

# Khởi tạo DataFrame để lưu metrics
models = ['inceptionv3', 'mobilenet', 'vgg16']
metrics = ['Accuracy', 'Precision', 'Recall', 'F1-score']
df_1F = pd.DataFrame(0, index=models, columns=metrics)

def trainningModel(modelName):
    global df_1F
    
    # 1. Load pre-trained model từ ImageNet
    if modelName == 'vgg16':
        base_model = VGG16(
            weights='imagenet', 
            include_top=False, 
            input_shape=input_shape
        )
    elif modelName == 'inceptionv3':
        base_model = InceptionV3(
            weights='imagenet', 
            include_top=False, 
            input_shape=input_shape
        )
    elif modelName == 'mobilenet':
        base_model = MobileNet(
            weights='imagenet', 
            include_top=False, 
            input_shape=input_shape
        )

    # 2. Freeze base model layers (Transfer Learning)
    for layer in base_model.layers:
        layer.trainable = False

    # 3. Thêm custom classification head
    model = tf_keras.models.Sequential([
        base_model,
        tf_keras.layers.BatchNormalization(),
        tf_keras.layers.Flatten(),
        tf_keras.layers.Dense(512, activation='relu'),
        tf_keras.layers.Dropout(0.5),
        tf_keras.layers.Dense(num_classes, activation='softmax')
    ])

    # 4. Compile model
    epochs = 50
    model.compile(
        loss='categorical_crossentropy', 
        optimizer='adam', 
        metrics=['accuracy']
    )
    print(model.summary())

    # 5. Training với Early Stopping
    callback = tf_keras.callbacks.EarlyStopping(
        monitor='val_loss', 
        patience=5, 
        restore_best_weights=True
    )
    model.fit(
        X_train, 
        y_train, 
        validation_data=(X_test, y_test), 
        epochs=epochs, 
        batch_size=32, 
        callbacks=callback
    )

    # 6. Evaluate model
    y_pred = model.predict(X_test)
    y_pred_classes = np.argmax(y_pred, axis=1)
    y_test_classes = np.argmax(y_test, axis=1)

    # 7. Tính metrics
    report = classification_report(
        y_test_classes, 
        y_pred_classes, 
        output_dict=True
    )
    accuracy = accuracy_score(y_test_classes, y_pred_classes)
    precision = report['weighted avg']['precision']
    recall = report['weighted avg']['recall']
    f1_score = report['weighted avg']['f1-score']

    # 8. Lưu metrics vào DataFrame
    df_1F.loc[modelName, 'Accuracy'] = round(accuracy, 2)
    df_1F.loc[modelName, 'Precision'] = round(precision, 2)
    df_1F.loc[modelName, 'Recall'] = round(recall, 2)
    df_1F.loc[modelName, 'F1-score'] = round(f1_score, 2)

    print(f'{modelName}: Accuracy={accuracy:.2f}, Precision={precision:.2f}, Recall={recall:.2f}, F1-score={f1_score:.2f}')

    # 9. Lưu model
    model_json = model.to_json()
    with open(f"model_{modelName}.json", "w") as json_file:
        json_file.write(model_json)
    model.save_weights(f"model_{modelName}.weights.h5")
    print("Saved model to disk")
```

---

### Bước 3: Training Các Models

#### 3.1. Training InceptionV3

```python
trainningModel("inceptionv3")
```

**Đặc điểm InceptionV3**:
- Input size: 244x244x3
- Pre-trained trên ImageNet
- Architecture: Inception modules với factorized convolutions
- Tốt cho: High accuracy, moderate speed

#### 3.2. Training MobileNet

```python
trainningModel("mobilenet")
```

**Đặc điểm MobileNet**:
- Input size: 244x244x3
- Pre-trained trên ImageNet
- Architecture: Depthwise separable convolutions
- Tốt cho: Mobile deployment, fast inference

#### 3.3. Training VGG16

```python
trainningModel("vgg16")
```

**Đặc điểm VGG16**:
- Input size: 244x244x3
- Pre-trained trên ImageNet
- Architecture: Deep convolutional layers (16 layers)
- Tốt cho: Feature extraction, transfer learning

---

## 🏗️ Kiến Trúc Models

### Transfer Learning Architecture

Tất cả 3 models đều sử dụng cùng một kiến trúc custom head:

```
Input Image (244x244x3)
    ↓
Pre-trained Base Model (Frozen)
    ├── InceptionV3 / MobileNet / VGG16
    └── Feature Extraction Layers
    ↓
BatchNormalization()
    ↓
Flatten()
    ↓
Dense(512, activation='relu')
    ↓
Dropout(0.5)  # 50% dropout để tránh overfitting
    ↓
Dense(num_classes=29, activation='softmax')
    ↓
Output: Probability distribution over 29 flower classes
```

### Hyperparameters

| Parameter | Value |
|-----------|-------|
| **Epochs** | 50 (với Early Stopping) |
| **Batch Size** | 32 |
| **Optimizer** | Adam |
| **Loss Function** | Categorical Crossentropy |
| **Early Stopping** | Monitor='val_loss', Patience=5 |
| **Input Size** | 244x244x3 |
| **Train/Test Split** | 80/20 |

### Transfer Learning Strategy

1. **Freeze Base Model**: Tất cả layers của pre-trained model được freeze
2. **Train Only Top Layers**: Chỉ train các layers mới được thêm vào
3. **Benefits**:
   - Training nhanh hơn
   - Ít dữ liệu cần thiết
   - Tận dụng features đã học từ ImageNet

---

## 🔀 Data Augmentation (Tùy Chọn)

### Augmentation cho InceptionV3

Một phiên bản training khác sử dụng data augmentation để tăng dataset:

```python
def cropFlower():
    root = '/content/drive/MyDrive/Dataset Flower/Dataset_29_flowers'
    for index, flower in enumerate(sorted(listdir(root))):
        path_flower = root + "/" + str(flower)
        for img in listdir(path_flower):
            path_img = path_flower + "/" + str(img)
            read_img = cv2.imread(path_img)

            # Resize về 299x299 (chuẩn cho InceptionV3)
            flower = cv2.resize(read_img, (299, 299), interpolation=cv2.INTER_AREA)
            
            # Augment với 5 biến thể cho mỗi ảnh gốc
            for _ in range(5):
                # Random rotation (0-360 độ)
                rotation_angle = np.random.randint(0, 360)
                rotated_flower = np.array(
                    Image.fromarray(flower).rotate(rotation_angle)
                )

                # Random horizontal flip (50% probability)
                if np.random.rand() > 0.5:
                    rotated_flower = cv2.flip(rotated_flower, 1)

                labels.append(index)
                img_list.append(rotated_flower)
```

**Augmentation Techniques**:
1. **Random Rotation**: 0-360 độ
2. **Horizontal Flip**: 50% probability
3. **Multiplier**: Tăng dataset lên 5 lần

**Lợi ích**:
- Tăng số lượng training samples
- Giảm overfitting
- Cải thiện generalization

---

## 📊 Đánh Giá và So Sánh Models

### Metrics Tracking

Sau khi training xong tất cả models, kết quả được lưu vào DataFrame:

```python
df_1F = df_1F.reset_index()
df_1F = df_1F.rename(columns={
    'index': 'Model name', 
    'Accuracy': 'Accuracy', 
    'Precision': 'Precision', 
    'Recall': 'Recall', 
    'F1-score': 'F1-score'
})
df_1F
```

### Metrics Được Tính

1. **Accuracy**: Tỷ lệ dự đoán đúng tổng thể
2. **Precision** (Weighted Average): Độ chính xác trung bình
3. **Recall** (Weighted Average): Độ nhạy trung bình
4. **F1-Score** (Weighted Average): Harmonic mean của Precision và Recall

### Classification Report

Mỗi model được đánh giá với `classification_report` từ sklearn:
- Per-class metrics
- Macro average
- Weighted average
- Support (số lượng samples mỗi class)

---

## 🧪 Testing và Inference

### Ensemble Prediction Function

```python
def modelPredict(modelName, flower):
    # Load model từ JSON và weights
    json_file = open('model_'+modelName+'.json', 'r')
    loaded_model_json = json_file.read()
    json_file.close()
    model = model_from_json(loaded_model_json)
    model.load_weights('model_'+modelName+'.h5')
    return model.predict(flower)

def recognitionFlower(pathImage):
    # 1. Load và preprocess ảnh
    img = cv2.imread(pathImage)
    flowerImage = cv2.resize(img, (299, 299), interpolation=cv2.INTER_AREA)
    cv2_imshow(flowerImage)  # Hiển thị ảnh
    
    flowerImage = np.array(flowerImage)
    flowerImage = flowerImage.astype('float32')
    flowerImage = np.expand_dims(flowerImage, axis=0)  # Add batch dimension
    flowerImage /= 255.0  # Normalize

    # 2. Predict với cả 3 models
    vgg16_predict = modelPredict("vgg16", flowerImage)
    inception_predict = modelPredict("inceptionv3", flowerImage)
    mobilenet_predict = modelPredict("mobilenet", flowerImage)

    # 3. Ensemble: Average predictions
    avg_predict = (vgg16_predict + inception_predict + mobilenet_predict) / 3

    # 4. Filter và sort predictions
    predictions = [
        (flowers[index], value) 
        for index, value in enumerate(avg_predict[0]) 
        if value >= 0.01  # Chỉ lấy predictions >= 1%
    ]
    predictions.sort(key=lambda x: x[1], reverse=True)  # Sort theo confidence

    # 5. Hiển thị kết quả
    for flower, value in predictions:
        print(flower + ': ' + str(int(value * 100)) + '%')
```

### Ensemble Strategy

**Phương pháp**: **Average Ensemble**
- Tính trung bình predictions từ 3 models
- Công thức: `avg_predict = (vgg16 + inceptionv3 + mobilenet) / 3`

**Lợi ích**:
- Giảm variance
- Tăng độ chính xác tổng thể
- Robust hơn với outliers

**Threshold**: Chỉ hiển thị predictions với confidence >= 1%

### Example Usage

```python
from google.colab.patches import cv2_imshow
from tf_keras.models import model_from_json

# Load flower class names
flowers = sorted(list(os.listdir("dataset/train")))
print(flowers)

# Test với ảnh sunflower
recognitionFlower("dataset/test/sunflower.jpg")
```

**Output Format**:
```
sunflower: 85%
rose: 12%
tulip: 3%
```

---

## 💾 Kết Quả và Lưu Trữ

### Model Files Được Lưu

Sau khi training, mỗi model được lưu thành 2 files:

1. **Model Architecture** (JSON):
   - `model_inceptionv3.json`
   - `model_mobilenet.json`
   - `model_vgg16.json`

2. **Model Weights** (H5):
   - `model_inceptionv3.weights.h5`
   - `model_mobilenet.weights.h5`
   - `model_vgg16.weights.h5`

### Metrics Summary

Kết quả metrics được lưu trong DataFrame `df_1F`:

| Model name | Accuracy | Precision | Recall | F1-score |
|------------|----------|-----------|--------|----------|
| inceptionv3 | X.XX | X.XX | X.XX | X.XX |
| mobilenet | X.XX | X.XX | X.XX | X.XX |
| vgg16 | X.XX | X.XX | X.XX | X.XX |

### Model Loading cho Production

```python
# Load model architecture
json_file = open('model_inceptionv3.json', 'r')
loaded_model_json = json_file.read()
json_file.close()
model = model_from_json(loaded_model_json)

# Load weights
model.load_weights('model_inceptionv3.weights.h5')

# Hoặc load trực tiếp từ .h5 (nếu đã save full model)
model = tf_keras.models.load_model('model_inceptionv3.h5')
```

---

## 🔍 Chi Tiết Kỹ Thuật

### Input Preprocessing

1. **Image Loading**: `cv2.imread()`
2. **Resize**: `cv2.resize(img, (244, 244), interpolation=cv2.INTER_AREA)`
3. **Normalization**: `img / 255.0` → [0, 1]
4. **Batch Dimension**: `np.expand_dims(img, axis=0)` → (1, 244, 244, 3)

### Training Process

1. **Transfer Learning**: Freeze base model, train only top layers
2. **Early Stopping**: Dừng training khi validation loss không cải thiện sau 5 epochs
3. **Best Weights**: Tự động restore weights tốt nhất khi early stopping
4. **Validation**: Sử dụng 20% test set để validate

### Model Architecture Details

**Custom Head**:
- **BatchNormalization**: Chuẩn hóa activations
- **Flatten**: Chuyển từ 3D → 1D
- **Dense(512)**: Fully connected layer với 512 neurons
- **Dropout(0.5)**: Regularization, giảm overfitting
- **Dense(29)**: Output layer với softmax activation

---

## 📈 Best Practices Đã Áp Dụng

1. ✅ **Transfer Learning**: Tận dụng pre-trained models
2. ✅ **Early Stopping**: Tránh overfitting
3. ✅ **Data Validation**: Kiểm tra file hợp lệ trước khi load
4. ✅ **Normalization**: Chuẩn hóa dữ liệu về [0, 1]
5. ✅ **Ensemble Learning**: Kết hợp nhiều models
6. ✅ **Reproducibility**: Fixed random seed
7. ✅ **Metrics Tracking**: Lưu và so sánh metrics
8. ✅ **Model Persistence**: Lưu cả architecture và weights

---

## 🚀 Cải Tiến Có Thể Áp Dụng

1. **Fine-tuning**: Unfreeze một số layers cuối của base model
2. **Learning Rate Scheduling**: Giảm learning rate theo epochs
3. **More Augmentation**: Thêm brightness, contrast, zoom
4. **Cross-Validation**: K-fold cross-validation thay vì single split
5. **Class Weighting**: Xử lý class imbalance
6. **Hyperparameter Tuning**: Tối ưu batch size, learning rate
7. **Model Checkpointing**: Lưu model sau mỗi epoch tốt nhất
8. **TensorBoard**: Visualization training process

---

## 📝 Kết Luận

Quy trình training này sử dụng **Transfer Learning** với 3 kiến trúc phổ biến và kết hợp chúng bằng **Ensemble Learning** để đạt độ chính xác cao trong nhận diện 29 loài hoa.

**Điểm mạnh**:
- Training nhanh nhờ Transfer Learning
- Ensemble approach tăng độ chính xác
- Code có cấu trúc rõ ràng, dễ maintain
- Hỗ trợ data augmentation

**Ứng dụng**: Models này được sử dụng trong Backend Flask API của dự án FlowerIdentifier để nhận diện hoa từ hình ảnh.

---

**Tài liệu được tạo từ Jupyter Notebook Training**  
**Ngày tạo**: 2024
