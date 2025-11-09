# SAFAR-Nexus Backend

FastAPI backend for road hazard detection and reporting system.

## Features

- User authentication (register, login) with JWT tokens
- Hazard reporting with image upload and GPS tagging
- Privacy-first: Automatic face and license plate blurring
- Spatial queries using PostGIS for nearby hazard retrieval
- Google Cloud Storage integration for image storage

## Tech Stack

- **Framework**: FastAPI 0.108.0
- **Database**: PostgreSQL 15 with PostGIS extension
- **Storage**: Google Cloud Storage
- **Image Processing**: OpenCV (face blurring)
- **Authentication**: JWT (30-day expiry for MVP)
- **ORM**: SQLAlchemy with GeoAlchemy2 for spatial data

## Setup

### Prerequisites

- Python 3.11+
- PostgreSQL 15 with PostGIS extension
- Google Cloud Platform account (for Cloud Storage)
- GCP service account with Storage Admin permissions

### Installation

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up PostgreSQL database:
```sql
CREATE DATABASE safar_nexus;
\c safar_nexus
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

4. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your actual values
```

5. Run database migrations (optional - tables are auto-created):
```bash
alembic upgrade head
```

6. Run the development server:
```bash
uvicorn app.main:app --reload
```

API will be available at: `http://localhost:8000`
API documentation: `http://localhost:8000/docs`

## API Endpoints

### Authentication

**POST /api/v1/auth/register**
- Create new user account
- Body: `{"email": "user@example.com", "password": "password123", "name": "User Name"}`
- Returns: JWT token and user details

**POST /api/v1/auth/login**
- Login existing user
- Body: `{"email": "user@example.com", "password": "password123"}`
- Returns: JWT token and user details

### Hazards

**POST /api/v1/hazards**
- Upload detected hazard with image
- Auth: Requires JWT Bearer token
- Content-Type: multipart/form-data
- Fields: image (file), latitude, longitude, confidence, timestamp, device_id
- Returns: hazard_id, blurred_image_url, status

**GET /api/v1/hazards/nearby**
- Get hazards within radius
- Auth: Requires JWT Bearer token
- Query params: latitude, longitude, radius_km (default 5), limit (default 100)
- Returns: List of nearby hazards with distances

**GET /api/v1/hazards/{hazard_id}**
- Get specific hazard details
- Auth: Requires JWT Bearer token
- Returns: Full hazard details

## Docker

Build and run with Docker:

```bash
docker build -t safar-nexus-backend .
docker run -p 8000:8000 --env-file .env safar-nexus-backend
```

## Deployment (Google Cloud Run)

1. Build and push to Container Registry:
```bash
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
    --set-env-vars DATABASE_URL=<connection-string>,JWT_SECRET_KEY=<secret>,GCS_BUCKET_NAME=safar-nexus-images \
    --add-cloudsql-instances <project>:<region>:<instance>
```

## Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI application entry point
│   ├── config.py            # Configuration and environment variables
│   ├── database.py          # Database connection setup
│   ├── dependencies.py      # FastAPI dependencies (JWT validation)
│   ├── utils.py             # Helper functions
│   ├── models/              # SQLAlchemy ORM models
│   │   ├── user.py
│   │   └── hazard.py
│   ├── schemas/             # Pydantic request/response schemas
│   │   ├── auth.py
│   │   └── hazard.py
│   ├── routers/             # API route handlers
│   │   ├── auth.py
│   │   └── hazards.py
│   └── services/            # Business logic
│       ├── auth_service.py  # JWT, password hashing
│       ├── image_service.py # Privacy blurring
│       └── storage_service.py # Google Cloud Storage
├── migrations/              # Alembic database migrations
├── tests/                   # Unit and integration tests
├── requirements.txt
├── Dockerfile
└── .env.example
```

## Environment Variables

- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET_KEY`: Secret key for JWT token signing (min 32 chars)
- `GCS_BUCKET_NAME`: Google Cloud Storage bucket name
- `GOOGLE_APPLICATION_CREDENTIALS`: Path to GCP service account JSON key

## Development

Run tests:
```bash
pytest tests/ -v
```

Format code:
```bash
black app/
```

## License

MIT
