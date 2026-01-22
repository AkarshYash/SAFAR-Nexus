# 🚀 How to Run SAFAR-Nexus

## Prerequisites

Your system needs:
- ✅ Python 3.11+ (You have Python 3.12.10 ✅)
- ❌ Docker Desktop (Not installed - optional)
- ❌ PostgreSQL (Not installed - we'll use SQLite instead)
- ❌ Redis (Not installed - optional for now)

## Quick Start (Without Docker)

### 1. Install Backend Dependencies

```bash
cd backend
pip install -r requirements.txt
```

Or install minimal dependencies:
```bash
pip install fastapi uvicorn[standard] sqlalchemy aiosqlite pydantic pydantic-settings python-jose[cryptography] passlib[bcrypt] python-multipart
```

### 2. Set Up Environment

The `.env` file is already created with SQLite configuration (no PostgreSQL needed for testing).

### 3. Initialize Database

```bash
cd backend
python -c "from app.db.base_class import Base; from app.models import *; import asyncio; from sqlalchemy.ext.asyncio import create_async_engine; asyncio.run(create_async_engine('sqlite+aiosqlite:///./safar_nexus.db').begin().run_sync(Base.metadata.create_all))"
```

Or use Alembic:
```bash
alembic upgrade head
```

### 4. Start Backend Server

```bash
cd backend
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

The API will be available at:
- **API**: http://localhost:8000
- **Docs**: http://localhost:8000/docs
- **Health**: http://localhost:8000/health

### 5. Test the API

Open your browser and go to:
- http://localhost:8000/docs

You'll see the interactive API documentation where you can:
1. Register a new user
2. Login to get a token
3. Create hazard reports
4. View nearby hazards
5. Check the leaderboard

## Mobile App Setup

### 1. Install Flutter

Download from: https://flutter.dev/docs/get-started/install

### 2. Install Dependencies

```bash
cd mobile
flutter pub get
```

### 3. Run on Emulator/Device

```bash
flutter run
```

## Testing Without Full Setup

You can test the backend API immediately:

### Test Health Endpoint
```bash
curl http://localhost:8000/health
```

### Register a User
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!",
    "full_name": "Test User"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }'
```

## What's Working Without External Services

✅ **Working Now:**
- User registration & authentication
- Hazard creation & retrieval
- Verification system
- Token/gamification
- Leaderboard
- WebSocket connections
- All API endpoints

❌ **Needs Configuration:**
- Push notifications (needs Firebase)
- Weather data (needs OpenWeather API key)
- Traffic data (needs Google Maps API key)
- Risk prediction (needs OpenAI API key)
- Email notifications (needs SMTP)

## Troubleshooting

### "Module not found" errors
```bash
pip install -r backend/requirements.txt
```

### "Database not found" errors
```bash
cd backend
alembic upgrade head
```

### Port 8000 already in use
```bash
# Use a different port
uvicorn app.main:app --reload --port 8001
```

### Import errors
Make sure you're in the backend directory:
```bash
cd backend
python -m uvicorn app.main:app --reload
```

## Next Steps

1. **Start the backend** (see step 4 above)
2. **Open the API docs** at http://localhost:8000/docs
3. **Test the endpoints** using the interactive UI
4. **Add API keys** to `.env` for full functionality
5. **Train AI models** for mobile app detection

## Full Production Setup

For production deployment with all features:

1. Install Docker Desktop
2. Run `docker-compose up -d`
3. Configure all API keys in `.env`
4. Train and place AI models
5. Deploy to cloud (AWS/GCP)

---

**Current Status**: Backend is ready to run with SQLite! Just install dependencies and start the server.
