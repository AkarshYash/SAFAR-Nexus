# SAFAR-Nexus

**Smart AI for Adaptive Road Safety - Nexus**

A next-generation road intelligence platform that transforms smartphone users into a collective sensor grid for real-time road hazard detection and prevention.

## Overview

SAFAR-Nexus uses computer vision and on-device AI to detect road hazards (potholes, speed breakers, debris) in real-time through smartphone cameras. The system geotags events, sends instant alerts to nearby drivers, and maintains end-to-end privacy by automatically blurring faces and license plates.

## 🎉 100% FREE Deployment Available!

Deploy SAFAR-Nexus with **ZERO cost** using completely FREE services - no credit card required!

```bash
./scripts/deploy-free.sh
```

**What you get:**
- ✅ Backend on Railway (500 hrs/month FREE)
- ✅ PostgreSQL + PostGIS on Neon (3GB FREE)
- ✅ Image storage on Cloudinary (25GB FREE)
- ✅ **Total: $0/month - No credit card needed!**

**Deployment time:** 5 minutes (automated)

👉 **Quick Start Guide:** [QUICKSTART_FREE.md](QUICKSTART_FREE.md)
📚 **Full FREE Guide:** [docs/DEPLOY_FREE.md](docs/DEPLOY_FREE.md)

---

### Key Features

- **Real-Time Detection**: YOLOv11-based pothole detection at 10-20 FPS
- **Privacy-First**: Automatic face and license plate blurring before upload
- **GPS Tagging**: Precise location tracking for all hazards
- **Cloud Storage**: Scalable image storage with Google Cloud Storage
- **Spatial Queries**: PostGIS-powered nearby hazard retrieval
- **Mobile-First**: Flutter app for Android and iOS
- **API-Driven**: RESTful FastAPI backend

## Architecture

```
┌─────────────────┐
│  Flutter App    │  (Mobile: Android/iOS)
│  - Camera AI    │
│  - GPS Tagging  │
│  - Map View     │
└────────┬────────┘
         │ HTTPS
         ▼
┌─────────────────┐
│  FastAPI Backend│  (Cloud Run)
│  - Auth (JWT)   │
│  - Image Blur   │
│  - PostGIS DB   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Google Cloud   │
│  - Cloud SQL    │
│  - Cloud Storage│
└─────────────────┘
```

## Project Structure

```
SAFAR-Nexus/
├── backend/                    # FastAPI backend
│   ├── app/
│   │   ├── main.py            # API entry point
│   │   ├── models/            # SQLAlchemy models
│   │   ├── routers/           # API endpoints
│   │   ├── services/          # Business logic
│   │   └── schemas/           # Pydantic schemas
│   ├── requirements.txt
│   ├── Dockerfile
│   └── README.md
│
├── mobile_app/                 # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/            # Data models
│   │   ├── services/          # API, Auth, Location, AI
│   │   ├── screens/           # UI screens
│   │   └── widgets/           # Reusable components
│   ├── assets/models/         # TFLite AI model
│   ├── pubspec.yaml
│   └── README.md
│
├── models/                     # AI models
│   └── training/              # Training scripts
│
└── docs/                       # Documentation
```

## Technology Stack

### Backend
- **Framework**: FastAPI (Python 3.11)
- **Database**: PostgreSQL 15 + PostGIS 3.3
- **Storage**: Google Cloud Storage
- **Image Processing**: OpenCV (face/license plate blurring)
- **Authentication**: JWT tokens with bcrypt
- **Deployment**: Docker + Google Cloud Run

### Mobile App
- **Framework**: Flutter 3.0+
- **AI/ML**: TensorFlow Lite (YOLOv11)
- **Camera**: camera package
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Storage**: SharedPreferences

## Quick Start

### Prerequisites

- Python 3.11+
- PostgreSQL 15 with PostGIS
- Flutter SDK 3.0+
- Google Cloud Platform account
- Google Maps API key

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Set up PostgreSQL:
```sql
CREATE DATABASE safar_nexus;
\c safar_nexus
CREATE EXTENSION postgis;
CREATE EXTENSION "uuid-ossp";
```

5. Configure environment:
```bash
cp .env.example .env
# Edit .env with your database credentials and GCP settings
```

6. Run the server:
```bash
uvicorn app.main:app --reload
```

API documentation: http://localhost:8000/docs

### Mobile App Setup

1. Navigate to mobile app directory:
```bash
cd mobile_app
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Configure API URL in `lib/utils/constants.dart`:
```dart
const String API_BASE_URL = "https://your-backend-url";
```

4. Add Google Maps API key:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/Info.plist`

5. Add AI model:
   - Place `pothole_detector.tflite` in `assets/models/`

6. Run the app:
```bash
flutter run
```

## Deployment

### Backend (Google Cloud Run)

1. Build Docker image:
```bash
cd backend
docker build -t gcr.io/<project-id>/safar-nexus-backend .
docker push gcr.io/<project-id>/safar-nexus-backend
```

2. Deploy to Cloud Run:
```bash
gcloud run deploy safar-nexus-api \
  --image gcr.io/<project-id>/safar-nexus-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-env-vars DATABASE_URL=<your-db-url>,JWT_SECRET_KEY=<secret>
```

### Mobile App

**Android:**
```bash
cd mobile_app
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Create new user
- `POST /api/v1/auth/login` - Login user

### Hazards
- `POST /api/v1/hazards` - Upload hazard with image
- `GET /api/v1/hazards/nearby` - Get nearby hazards
- `GET /api/v1/hazards/{id}` - Get hazard details

Full API documentation: `/docs` endpoint on running backend

## AI Model

The system uses YOLOv11 (nano variant) for pothole detection.

### Acquiring the Model

**Option 1**: Download pre-trained model from Roboflow Universe
- Search for "pothole detection" datasets
- Export as TensorFlow Lite format

**Option 2**: Train custom model
1. Collect 500+ pothole images
2. Annotate with bounding boxes
3. Train YOLOv11n using Ultralytics
4. Convert to TFLite format

### Conversion Pipeline

```bash
# Export YOLO to ONNX
yolo export model=yolov11n.pt format=onnx

# Convert ONNX to TensorFlow
onnx-tf convert -i yolov11n.onnx -o yolov11n_tf

# Convert to TFLite with quantization
tflite_convert --saved_model_dir=yolov11n_tf \
  --output_file=pothole_detector.tflite \
  --optimizations=DEFAULT
```

## Database Schema

### Users Table
- `user_id` (UUID, primary key)
- `email` (unique)
- `password_hash` (bcrypt)
- `name`
- `created_at`, `updated_at`

### Hazards Table
- `hazard_id` (UUID, primary key)
- `user_id` (foreign key)
- `location` (PostGIS geography point)
- `latitude`, `longitude`
- `confidence` (0.0-1.0)
- `image_url`
- `detected_at`, `created_at`

Spatial index on `location` for fast nearby queries using PostGIS `ST_DWithin`.

## Privacy & Security

- **Face Detection**: Haar Cascade + Gaussian blur (backend)
- **License Plate**: Planned (YOLO-based detection + blur)
- **Authentication**: JWT tokens with 30-day expiry
- **Password Hashing**: Bcrypt with cost factor 12
- **HTTPS**: All communication encrypted
- **Data Minimization**: Only essential data collected

## Performance Targets

- **Detection Accuracy**: >85% mAP on potholes
- **Inference Speed**: <50ms per frame (mobile)
- **API Response Time**: <300ms for hazard queries
- **False Positive Rate**: <5%
- **Upload Latency**: <2 seconds per detection

## Roadmap

### MVP (Current Phase)
- [x] Backend API with authentication
- [x] PostgreSQL with PostGIS spatial queries
- [x] Flutter app with camera integration
- [x] YOLOv11 TFLite model structure
- [x] Google Maps hazard visualization
- [x] Privacy blurring (backend)

### Phase 2
- [ ] On-device privacy blurring
- [ ] Sensor fusion (accelerometer + audio)
- [ ] Real-time alerts to nearby drivers
- [ ] Duplicate detection across users
- [ ] Social verification system

### Phase 3
- [ ] Predictive risk mapping (LangChain)
- [ ] Civic integration APIs
- [ ] Gamification & SAFAR tokens
- [ ] Federated learning
- [ ] Analytics dashboard

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Team

**MARU WARRIORS**
- Akarsh Chaturvedi (Leader)
- Devansh Gupta
- Suhani Sharma
- Niraj Karal

## License

MIT License - see LICENSE file for details

## Acknowledgments

- YOLOv11 by Ultralytics
- FastAPI framework
- Flutter team
- PostGIS community
- Google Cloud Platform

## Contact

For questions or support, please open an issue on GitHub.

---

**SAFAR-Nexus** - Making roads safer, one detection at a time.
