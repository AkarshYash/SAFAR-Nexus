# SAFAR-Nexus Quick Start Guide

Get SAFAR-Nexus running in 5 minutes!

---

## Option 1: Local Testing (Fastest)

Perfect for testing and development without cloud setup.

### 1. Start Backend with Docker

```bash
# One command to start everything!
./scripts/local-test.sh

# Or manually:
docker-compose up -d
```

**Services running:**
- Backend API: http://localhost:8000
- Database: localhost:5432
- API Docs: http://localhost:8000/docs

### 2. Test Backend

```bash
# Register a user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test1234","name":"Test User"}'

# Check health
curl http://localhost:8000/health
```

### 3. Run Mobile App

```bash
cd mobile_app

# Update API URL to local
# Edit lib/utils/constants.dart:
# const String API_BASE_URL = "http://10.0.2.2:8000";  // For Android emulator

# Install dependencies
flutter pub get

# Run app
flutter run
```

**Done!** App is connected to local backend.

---

## Option 2: Deploy to Production (GCP)

Deploy to Google Cloud Platform for production use.

### Prerequisites

- Google Cloud account with billing
- gcloud CLI installed
- Project created

### 1. Set Environment

```bash
# Set your GCP project ID
export GCP_PROJECT_ID="your-project-id"

# Authenticate
gcloud auth login
gcloud config set project $GCP_PROJECT_ID
```

### 2. Deploy Backend (Automated)

```bash
# Run deployment script
./scripts/deploy-backend-gcp.sh

# Follow prompts and wait 5-10 minutes
```

**What it does:**
- Creates Cloud SQL database
- Creates Cloud Storage bucket
- Builds Docker image
- Deploys to Cloud Run
- Outputs service URL

### 3. Configure Mobile App

```bash
# Edit mobile_app/lib/utils/constants.dart
# Update API_BASE_URL with the Cloud Run URL from step 2

# Add Google Maps API keys:
# - android/app/src/main/AndroidManifest.xml
# - ios/Runner/Info.plist

# Add AI model:
# Place pothole_detector.tflite in assets/models/
```

### 4. Build & Deploy Mobile

```bash
# Build Android APK
./scripts/build-mobile.sh

# Or manually:
cd mobile_app
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

**Done!** Backend deployed, mobile app built.

---

## What You Need

### For Local Testing

✅ Docker & Docker Compose
✅ Flutter SDK
✅ Nothing else!

### For Production Deployment

✅ Google Cloud account ($300 free credit for new users)
✅ Google Maps API key (free tier: 28k requests/month)
✅ AI model file (see models/README.md)
✅ gcloud CLI installed

---

## Quick Commands Reference

### Local Development

```bash
# Start all services
./scripts/local-test.sh

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down

# Run mobile app
cd mobile_app && flutter run

# Build mobile app
./scripts/build-mobile.sh
```

### Production

```bash
# Deploy backend to GCP
./scripts/deploy-backend-gcp.sh

# View backend logs
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Update backend
docker build -t gcr.io/$GCP_PROJECT_ID/safar-nexus-backend backend/
docker push gcr.io/$GCP_PROJECT_ID/safar-nexus-backend
gcloud run deploy safar-nexus-api --image gcr.io/$GCP_PROJECT_ID/safar-nexus-backend --region asia-south1
```

---

## Troubleshooting

### "Docker not found"
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### "Flutter not found"
```bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

### "gcloud not found"
```bash
# Install gcloud
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

### Backend not responding
```bash
# Check if services are running
docker-compose ps

# Restart services
docker-compose restart backend

# Check logs
docker-compose logs backend
```

### Mobile app can't connect
```bash
# Check backend URL in constants.dart
# For emulator use: http://10.0.2.2:8000
# For physical device use your machine's IP

# Test backend from mobile device browser
# Visit: http://YOUR_IP:8000/health
```

---

## Next Steps

1. **Read Full Documentation**
   - Main: `README.md`
   - Deployment: `docs/DEPLOYMENT.md`
   - API Reference: `docs/API.md`

2. **Get AI Model**
   - See: `models/README.md`
   - Download from Roboflow or train custom

3. **Configure Maps**
   - Get API key: https://console.cloud.google.com/apis
   - Enable Maps SDK for Android/iOS

4. **Set Up CI/CD**
   - See: `.github/workflows/ci-cd.yml`
   - Add GitHub secrets
   - Enable workflows

5. **Monitor & Scale**
   - View logs in GCP Console
   - Set up alerts
   - Configure autoscaling

---

## Cost Estimate

### Local (Development)
**Free** - Only uses local resources

### Production (Minimal Usage)
- Cloud Run: **$0** (free tier)
- Cloud SQL: **~$10/month**
- Cloud Storage: **~$1/month**
- **Total: ~$11/month**

*$300 free credit for new GCP users covers ~27 months*

---

## Support

**Documentation:** All `.md` files in repository
**Issues:** GitHub Issues
**Logs:** `docker-compose logs` or GCP Console

---

## Summary

**Local Testing:** `./scripts/local-test.sh` → Done in 2 minutes
**Production Deploy:** `./scripts/deploy-backend-gcp.sh` → Done in 10 minutes
**Mobile Build:** `./scripts/build-mobile.sh` → Done in 5 minutes

**Total Time:** 20 minutes from zero to production! 🚀

---

*SAFAR-Nexus - Making roads safer, one detection at a time.*
