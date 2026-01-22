# SAFAR-Nexus

**Smart AI for Adaptive Road Safety - Nexus**

From Reactive Reporting to Predictive Prevention

## Overview

SAFAR-Nexus is a next-generation road intelligence platform that transforms smartphone users into a collective sensor grid for detecting and predicting road hazards in real-time.

## Features

- **Multi-Modal AI Detection**: Camera, accelerometer, gyroscope, and microphone fusion
- **Privacy-First**: On-device processing with automatic face/license plate blurring
- **Predictive Risk Mapping**: LangChain-powered hazard prediction
- **Real-Time Alerts**: Context-aware voice warnings
- **Automated Civic Reporting**: Direct integration with municipal systems
- **Federated Learning**: Privacy-preserving model improvement
- **Gamification**: SAFAR token rewards for contributions

## Project Structure

```
safar-nexus/
├── backend/              # FastAPI backend services
│   ├── app/
│   │   ├── api/         # API endpoints
│   │   ├── core/        # Configuration
│   │   ├── models/      # Database models
│   │   ├── services/    # Business logic
│   │   └── main.py      # Application entry
│   ├── Dockerfile
│   └── requirements.txt
├── mobile/              # Flutter mobile app
│   ├── lib/
│   │   ├── models/
│   │   ├── services/
│   │   ├── screens/
│   │   └── main.dart
│   └── pubspec.yaml
├── ml/                  # ML models and training
│   ├── models/
│   └── training/
├── docker-compose.yml
└── README.md
```

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Python 3.11+
- Flutter 3.0+
- PostgreSQL with PostGIS
- Redis

### Backend Setup

```bash
# Copy environment variables
cp backend/.env.example backend/.env

# Start services with Docker Compose
docker-compose up -d

# Backend will be available at http://localhost:8000
```

### Mobile App Setup

```bash
cd mobile
flutter pub get
flutter run
```

## Development

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Database Migrations

```bash
cd backend
alembic revision --autogenerate -m "description"
alembic upgrade head
```

## API Documentation

Once the backend is running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Technology Stack

### Backend
- FastAPI (Python)
- PostgreSQL + PostGIS
- Redis
- Celery
- LangChain
- TensorFlow

### Mobile
- Flutter
- TensorFlow Lite
- SQLite
- Firebase

### Infrastructure
- Docker
- Kubernetes
- AWS/GCP

## Team

**MARU WARRIORS**
- Akarsh Chaturvedi (Leader)
- Devansh Gupta
- Suhani Sharma
- Niraj Karal


https://github.com/user-attachments/assets/4d6056d7-416f-4569-9b4b-b3acf48bd798


- 

## License

Copyright © 2025 MARU WARRIORS
