# Tài Liệu Dự Án FlowerIdentifier

## 📋 Mục Lục
1. [Tổng Quan Dự Án](#tổng-quan-dự-án)
2. [Công Nghệ Sử Dụng](#công-nghệ-sử-dụng)
3. [Kiến Trúc Hệ Thống](#kiến-trúc-hệ-thống)
4. [Trải Nghiệm Người Dùng (UX)](#trải-nghiệm-người-dùng-ux)
5. [Model AI](#model-ai)
6. [API Endpoints](#api-endpoints)
7. [Cấu Trúc Dự Án](#cấu-trúc-dự-án)

---

## 🎯 Tổng Quan Dự Án

**FlowerIdentifier** là một ứng dụng đa nền tảng cho phép người dùng nhận diện hoa thông qua hình ảnh sử dụng công nghệ AI. Dự án bao gồm:

- **Backend API**: Flask server cung cấp dịch vụ nhận diện hoa và mô tả thông tin
- **Android App**: Ứng dụng mobile native được xây dựng bằng Kotlin
- **Web App**: Ứng dụng web social network cho cộng đồng yêu hoa (Next.js)

### Tính Năng Chính
- ✅ Nhận diện hoa từ hình ảnh sử dụng Deep Learning
- ✅ Mô tả chi tiết về hoa (mô tả, loài, cách chăm sóc)
- ✅ Chatbot AI để tư vấn về hoa
- ✅ Lưu trữ lịch sử nhận diện
- ✅ Social network: chia sẻ, tương tác, nhóm cộng đồng (Web)

---

## 🛠️ Công Nghệ Sử Dụng

### Backend (Flask API)

#### Framework & Core Libraries
```python
flask>=2.3.0              # Web framework
flask-cors>=4.0.0         # Cross-Origin Resource Sharing
werkzeug>=2.3.0           # WSGI utilities
```

#### Machine Learning & Computer Vision
```python
tensorflow>=2.13.0        # Deep learning framework
keras>=2.13.0             # High-level neural network API
opencv-python>=4.8.0      # Computer vision library
numpy>=1.24.0             # Numerical computing
pillow>=10.0.0            # Image processing
```

#### AI Services Integration
```python
openai>=1.0.0             # OpenAI GPT API client
google-generativeai>=0.3.0 # Google Gemini API client
python-dotenv>=1.0.0      # Environment variables management
```

**Đặc điểm Backend:**
- Pre-load models khi khởi động để tối ưu hiệu suất
- Hỗ trợ CORS cho mobile apps
- Xử lý lỗi robust với fallback mechanisms
- Hỗ trợ multiple AI providers (OpenAI, Gemini, Groq)

---

### Android App

#### Core Technologies
- **Language**: Kotlin 1.7+
- **Min SDK**: 24 (Android 7.0)
- **Target SDK**: 34 (Android 14)
- **Architecture**: MVVM (Model-View-ViewModel)

#### Key Libraries

**UI & Navigation**
```kotlin
androidx.appcompat:appcompat:1.6.1
com.google.android.material:material:1.8.0
androidx.constraintlayout:constraintlayout:2.1.4
```

**Networking**
```kotlin
com.squareup.retrofit2:retrofit:2.9.0
com.squareup.retrofit2:converter-gson:2.9.0
com.squareup.okhttp3:okhttp:4.10.0
```

**Architecture Components**
```kotlin
androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.0
androidx.lifecycle:lifecycle-livedata-ktx:2.6.0
androidx.room:room-runtime:2.6.1
androidx.room:room-ktx:2.6.1
```

**Dependency Injection**
```kotlin
io.insert-koin:koin-core:3.2.0
io.insert-koin:koin-android:3.2.0
```

**Image Loading**
```kotlin
com.github.bumptech.glide:glide:4.14.2
```

**Firebase**
```kotlin
com.google.firebase:firebase-messaging:24.0.0  # Push notifications
```

**AI Integration**
```kotlin
com.aallam.openai:openai-client:3.0.0  # OpenAI client for Kotlin
```

**Đặc điểm Android App:**
- Material Design UI với blur effects
- Offline-first với Room database
- Real-time updates với LiveData
- Image picker integration
- Push notifications với Firebase Cloud Messaging

---

### Web App (Next.js)

#### Core Technologies
- **Framework**: Next.js 16 (App Router)
- **Language**: TypeScript 5+
- **Styling**: Tailwind CSS v4
- **UI Components**: shadcn/ui (Radix UI based)

#### Key Dependencies

**Core Framework**
```json
"next": "16.0.10"
"react": "19.2.0"
"react-dom": "19.2.0"
"typescript": "^5"
```

**UI & Styling**
```json
"tailwindcss": "^4.1.9"
"@radix-ui/react-*": "1.x.x"  // Component library
"lucide-react": "^0.454.0"    // Icons
"class-variance-authority": "^0.7.1"
```

**Backend & Database**
```json
"@supabase/ssr": "0.8.0"
"@supabase/supabase-js": "latest"
```

**Form & Validation**
```json
"react-hook-form": "^7.60.0"
"@hookform/resolvers": "^3.10.0"
"zod": "3.25.76"
```

**Đặc điểm Web App:**
- Server-side rendering (SSR) với Next.js
- Real-time features với Supabase Realtime
- Responsive design với Tailwind CSS
- Type-safe với TypeScript
- Social features: feed, groups, messaging, notifications

---

## 🏗️ Kiến Trúc Hệ Thống

### Backend Architecture

```
┌─────────────────────────────────────────┐
│         Flask API Server                │
│  (main.py - Port 5000)                  │
├─────────────────────────────────────────┤
│  Endpoints:                              │
│  - POST /recognition                     │
│  - GET  /description/<nameFlower>       │
│  - POST /chat                            │
└─────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ TensorFlow│   │  OpenAI   │   │  Gemini  │
    │  Models   │   │   GPT     │   │   API    │
    └──────────┘   └──────────┘   └──────────┘
           │              │              │
           ▼              ▼              ▼
    ┌──────────────────────────────────────┐
    │   AI Recognition & Description       │
    └──────────────────────────────────────┘
```

### Android App Architecture

```
┌─────────────────────────────────────────┐
│         UI Layer (Activities/Fragments) │
│  - MainActivity                         │
│  - RecognitionActivity                  │
│  - ChatActivity                         │
│  - DescriptionFlowerActivity            │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      ViewModel Layer (MVVM)             │
│  - RecognitionVM                         │
│  - ChatViewModel                         │
│  - FlowerVM                              │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      Repository Layer                   │
│  - Local Repository (Room)               │
│  - Remote Repository (Retrofit)           │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      Data Sources                       │
│  - Room Database (Local)                 │
│  - Flask API (Remote)                    │
│  - Supabase (Profile/Social)             │
└─────────────────────────────────────────┘
```

### Web App Architecture

```
┌─────────────────────────────────────────┐
│      Next.js App Router                  │
│  - Server Components (SSR)              │
│  - Client Components (Interactive)       │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      Supabase Integration                │
│  - Authentication                        │
│  - PostgreSQL Database                   │
│  - Storage (Images)                      │
│  - Realtime (Chat/Notifications)         │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      Flask API Integration               │
│  - Flower Recognition                    │
│  - AI Chat                               │
└─────────────────────────────────────────┘
```

---

## 🎨 Trải Nghiệm Người Dùng (UX)

### Android App UX Flow

#### 1. **Màn Hình Chính (MainActivity)**
- **Layout**: Bottom Navigation với ViewPager
- **Features**:
  - Floating Action Button (FAB) để chụp/chọn ảnh
  - Navigation Drawer với profile, chat, notifications
  - Blur background effect (Android 12+)
  - Tab navigation: Home, My Plants

#### 2. **Nhận Diện Hoa (RecognitionActivity)**
- **Flow**:
  1. User chọn/chụp ảnh từ MainActivity
  2. Hiển thị dialog chọn khu vực địa lý (Area Selection)
  3. Upload ảnh lên server
  4. Hiển thị loading với progress indicator
  5. Hiển thị kết quả top 2 hoa được nhận diện
  6. User có thể click vào kết quả để xem chi tiết

- **UX Features**:
  - Blur background effect
  - Smooth transitions
  - Error handling với thông báo rõ ràng
  - RecyclerView hiển thị kết quả với match rate

#### 3. **Mô Tả Hoa (DescriptionFlowerActivity)**
- **Content**:
  - Tên hoa
  - Mô tả tổng quan (AI-generated)
  - Danh sách loài (AI-generated)
  - Hướng dẫn chăm sóc (AI-generated)
  - Hình ảnh tương tự (nếu có)

#### 4. **Chatbot (ChatActivity)**
- **Features**:
  - Real-time chat interface
  - Message history lưu trong Room database
  - Loading states
  - Clear history button
  - Auto-scroll to latest message

#### 5. **My Plants (Home Fragment)**
- Hiển thị lịch sử các hoa đã nhận diện
- Lưu trữ local với Room database

### Web App UX Flow

#### 1. **Authentication Flow**
- Login/Signup với Supabase Auth
- Email verification
- Password reset

#### 2. **Onboarding**
- Personalized setup cho new users
- Chọn interests và preferences

#### 3. **Main Feed**
- Social feed với approved posts
- Like, comment, share interactions
- Infinite scroll
- Post filtering

#### 4. **Upload Flow**
- Multi-image upload (up to 5 images)
- AI flower recognition integration
- Caption, location tagging
- Post moderation (pending → approved)

#### 5. **Social Features**
- **Groups**: Create/join flower communities
- **Messages**: Real-time 1-on-1 chat
- **Notifications**: Real-time updates
- **Profile**: Customizable với avatar, bio

#### 6. **Admin Dashboard**
- Post moderation
- User management
- Reports handling
- Platform statistics

### Design Principles

#### Android App
- **Material Design 3**: Modern, clean interface
- **Blur Effects**: Depth và visual hierarchy
- **Smooth Animations**: Transitions giữa screens
- **Offline Support**: Local caching với Room
- **Error Handling**: User-friendly error messages

#### Web App
- **Responsive Design**: Mobile-first approach
- **Dark Mode**: Theme switching support
- **Accessibility**: ARIA labels, keyboard navigation
- **Performance**: SSR, image optimization
- **Real-time Updates**: Supabase Realtime subscriptions

---

## 🤖 Model AI

### 1. Flower Recognition Models

#### Architecture
Dự án sử dụng **ensemble approach** với 3 pre-trained models:

1. **InceptionV3**
   - Architecture: Inception v3 (Google)
   - Input size: 244x244x3
   - Pre-trained trên ImageNet, fine-tuned cho flower classification

2. **MobileNet**
   - Architecture: MobileNet (Google)
   - Input size: 224x224x3
   - Lightweight, optimized cho mobile devices

3. **VGG16**
   - Architecture: VGG16 (Oxford)
   - Input size: 224x224x3
   - Deep convolutional network

#### Model Loading Strategy
```python
# Pre-load models at startup
init_models()  # Loads all 3 models into memory
```

**Lợi ích:**
- Giảm latency khi nhận diện
- Models được cache trong memory
- Parallel prediction với ensemble voting

#### Recognition Process

1. **Image Preprocessing**:
   ```python
   # Resize to 244x244
   img = cv2.resize(image, (244, 244))
   # Normalize to [0, 1]
   img = img.astype('float32') / 255.0
   # Add batch dimension
   img = np.expand_dims(img, axis=0)
   ```

2. **Ensemble Prediction**:
   - Mỗi model predict độc lập
   - Lấy top prediction từ mỗi model
   - Sort theo confidence score
   - Return top 2 results

3. **Output Format**:
   ```json
   {
     "name_flower": "rose",
     "areas": ["Grassland and Meadow", "Temperate"],
     "match_rate": 85
   }
   ```

#### Supported Flowers (38 classes)
- bluebell, carnation, Dahlia, Forget-Me-Not, Frangipani
- Jasmine, Marigold, Mimosa, Orchid, Zinnia
- astilbe, bellflower, black_eyed_susan, buttercup
- calendula, california_poppy, cherryblossom
- coltsfoot, common daisy, coreopsis, cowslip
- crocus, daffodil, daisy, dandelion, fritillary
- iris, lily, lilyvalley, magnolia, pansy
- rose, snowdrop, sunflower, tigerlily, tulip
- water_lily, windflower, scorpion grasses

#### Geographic Areas Mapping
Mỗi loài hoa được map với các khu vực địa lý:
- Tropical Rainforest
- Temperate
- Subtropical
- Mediterranean
- Grassland and Meadow
- Woodland and Shrubland
- Alpine and Montane
- Wetland and Riparian
- Desert
- Coastal Areas
- ... và nhiều hơn

---

### 2. Large Language Models (LLMs)

#### OpenAI GPT Integration

**Model**: `gpt-4o-mini` (default)
- **Use Cases**:
  - Flower descriptions
  - Species information
  - Care instructions
  - Chatbot conversations

**Implementation**:
```python
# Description generation
callGpt.callGPT("Description " + nameFlower + " limited to 100 words")

# Chat completion
callGpt.chat(
    messages=messages,
    model="gpt-4o-mini",
    system=system_prompt,
    stream=False
)
```

**Features**:
- Streaming support
- System prompts
- Message history
- Error handling với fallback

---

#### Google Gemini Integration

**Model**: `gemini-2.0-flash` (default)
- **Use Cases**: Alternative LLM provider
- **Features**:
  - System instructions
  - Chat history
  - Streaming support
  - Fallback to default model nếu model không tồn tại

**Implementation**:
```python
callGemini.chat(
    messages=messages,
    model="gemini-2.0-flash",
    system=system_instruction,
    stream=False
)
```

---

#### Groq Integration

**Models Supported**:
- `llama-3.3-70b-versatile`
- `mixtral-8x7b-32768`
- `gemma-7b-it`

**Use Cases**: Fast inference với open-source models
- **Features**:
  - High-speed inference
  - OpenAI-compatible API
  - Multiple model options

**Implementation**:
```python
callGroq.chat(
    messages=messages,
    model="llama-3.3-70b-versatile",
    system=system_prompt,
    stream=False
)
```

---

### 3. Model Selection Logic

Backend tự động chọn AI provider dựa trên model name:

```python
if model.startswith('gemini'):
    # Use Gemini
    reply = callGemini.chat(...)
elif model.startswith('llama') or model.startswith('mixtral') or model.startswith('gemma'):
    # Use Groq
    reply = callGroq.chat(...)
else:
    # Use OpenAI GPT (default)
    reply = callGpt.chat(...)
```

---

### 4. AI Workflow

#### Flower Recognition Workflow
```
User uploads image
    ↓
Backend receives image
    ↓
Preprocess image (resize, normalize)
    ↓
Run ensemble prediction (3 models)
    ↓
Aggregate results (top 2)
    ↓
Return JSON response
```

#### Description Generation Workflow
```
User requests description
    ↓
Backend calls GPT API (3 parallel calls)
    ↓
- Description generation
- Species list generation
- Care instructions generation
    ↓
Combine into Flower object
    ↓
Return JSON response
```

#### Chat Workflow
```
User sends message
    ↓
Backend determines model provider
    ↓
Call appropriate LLM API
    ↓
Stream/return response
    ↓
Update chat history
```

---

## 🔌 API Endpoints

### Backend API (Flask)

#### 1. POST /recognition
**Purpose**: Nhận diện hoa từ hình ảnh

**Request**:
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body: `file` (image file)

**Response**:
```json
{
  "status": "success",
  "message": "File uploaded successfully",
  "results": [
    {
      "name_flower": "rose",
      "areas": ["Grassland and Meadow", "Temperate"],
      "match_rate": 85
    },
    {
      "name_flower": "tulip",
      "areas": ["Grassland and Meadow", "Temperate"],
      "match_rate": 12
    }
  ]
}
```

---

#### 2. GET /description/<nameFlower>
**Purpose**: Lấy mô tả chi tiết về hoa

**Request**:
- Method: `GET`
- Path parameter: `nameFlower` (e.g., "rose")

**Response**:
```json
{
  "status": "success",
  "message": "Description rose",
  "flower": {
    "name": "rose",
    "desc": "Roses are flowering plants...",
    "species": "Rosa damascena, Rosa gallica...",
    "care": "Water regularly, provide sunlight..."
  }
}
```

---

#### 3. POST /chat
**Purpose**: Chat với AI

**Request**:
- Method: `POST`
- Content-Type: `application/json`
- Body:
```json
{
  "messages": [
    {"role": "user", "content": "How to care for roses?"}
  ],
  "system": "You are a flower expert assistant.",
  "model": "gpt-4o-mini"
}
```

**Response**:
```json
{
  "status": "success",
  "message": "ok",
  "reply": "Roses require regular watering..."
}
```

**Supported Models**:
- OpenAI: `gpt-4o-mini`, `gpt-4`, `gpt-3.5-turbo`
- Gemini: `gemini-2.0-flash`, `gemini-pro`
- Groq: `llama-3.3-70b-versatile`, `mixtral-8x7b-32768`, `gemma-7b-it`

---

## 📁 Cấu Trúc Dự Án

```
DATN/
├── BackEnd/                    # Flask API Server
│   ├── main.py                # Entry point
│   ├── requirements.txt       # Python dependencies
│   ├── feature/
│   │   ├── recognition/
│   │   │   ├── recognitionFlower.py
│   │   │   └── model/         # TensorFlow models
│   │   │       ├── model_inceptionv3.h5
│   │   │       ├── model_mobilenet.h5
│   │   │       └── model_vgg16.h5
│   │   └── description/
│   │       ├── callGpt.py
│   │       ├── callGemini.py
│   │       └── callGroq.py
│   └── model/
│       └── Flower.py          # Data model
│
├── app/                        # Android App
│   ├── build.gradle
│   └── src/main/java/com/example/floweridentifier/
│       ├── ui/                # UI layer
│       │   ├── main/
│       │   ├── recognition/
│       │   ├── chatbot/
│       │   └── descflower/
│       ├── data/              # Data layer
│       │   ├── database/      # Room database
│       │   ├── model/         # Data models
│       │   └── repository/    # Repository pattern
│       └── utils/             # Utilities
│
└── Web/                        # Next.js Web App
    ├── app/                   # App Router pages
    │   ├── auth/
    │   ├── feed/
    │   ├── upload/
    │   ├── groups/
    │   ├── messages/
    │   └── admin/
    ├── components/            # React components
    │   ├── ui/               # shadcn/ui components
    │   └── ...
    ├── lib/                  # Utilities
    │   ├── supabase/
    │   └── ai/
    └── scripts/              # SQL migrations
```

---

## 🚀 Deployment

### Backend
- **Local**: `python BackEnd/main.py`
- **Production**: Deploy Flask app với Gunicorn hoặc uWSGI
- **Tunneling**: Sử dụng ngrok cho development

### Android App
- **Build**: `./gradlew assembleRelease`
- **Distribution**: Google Play Store hoặc APK file

### Web App
- **Development**: `npm run dev`
- **Production**: Deploy lên Vercel (recommended) hoặc self-hosted
- **Database**: Supabase (managed PostgreSQL)

---

## 📝 Environment Variables

### Backend (.env)
```
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=...
GROQ_API_KEY=...
```

### Web App (.env.local)
```
NEXT_PUBLIC_SUPABASE_URL=https://...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
```

---

## 🔒 Security

- API keys được lưu trong environment variables
- CORS được cấu hình cho mobile apps
- Supabase RLS (Row Level Security) cho database
- Secure file upload với validation
- Authentication với Supabase Auth

---

## 📊 Performance Optimizations

### Backend
- Pre-load models tại startup
- Model caching trong memory
- Image preprocessing optimization
- Async API calls

### Android
- Room database caching
- Glide image loading với caching
- ViewBinding để giảm findViewById calls
- Coroutines cho async operations

### Web
- Next.js SSR/SSG
- Image optimization
- Supabase Realtime subscriptions
- Client-side caching

---

## 🎓 Kết Luận

Dự án **FlowerIdentifier** là một hệ thống hoàn chỉnh tích hợp:
- **Deep Learning** cho nhận diện hình ảnh
- **Large Language Models** cho mô tả và chatbot
- **Modern Web Technologies** cho social features
- **Native Mobile App** cho trải nghiệm tốt nhất

Hệ thống được thiết kế với kiến trúc modular, dễ mở rộng và maintain.

---

**Tài liệu được tạo tự động từ codebase**  
**Cập nhật lần cuối**: 2024
