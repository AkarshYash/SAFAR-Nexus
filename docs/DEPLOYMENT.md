# SAFAR-Nexus Deployment Guide

Complete deployment guide for production and local testing.

---

## Table of Contents

1. [Local Testing with Docker Compose](#local-testing)
2. [Production Deployment to Google Cloud](#production-deployment)
3. [Mobile App Deployment](#mobile-app-deployment)
4. [CI/CD Pipeline Setup](#cicd-setup)
5. [Post-Deployment Checklist](#post-deployment-checklist)

---

## Local Testing

### Prerequisites

- Docker & Docker Compose installed
- At least 4GB RAM available
- Ports 5432, 8000, 80 available

### Quick Start

```bash
# Run the automated setup script
./scripts/local-test.sh

# Or manually:
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

### Local Services

Once running, access:

- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Database**: localhost:5432
  - Database: `safar_nexus`
  - User: `safar_user`
  - Password: `safar_password_change_in_production`

### Test Backend

```bash
# Register user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test1234","name":"Test User"}'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test1234"}'

# Health check
curl http://localhost:8000/health
```

### Connect Mobile App to Local Backend

Update `mobile_app/lib/utils/constants.dart`:

```dart
// For Android emulator
const String API_BASE_URL = "http://10.0.2.2:8000";

// For iOS simulator
const String API_BASE_URL = "http://localhost:8000";

// For physical device (use your machine's IP)
const String API_BASE_URL = "http://192.168.1.100:8000";
```

---

## Production Deployment

### Prerequisites

1. **Google Cloud Platform Account**
   - Billing enabled
   - Project created

2. **gcloud CLI Installed**
   ```bash
   # Install gcloud
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   gcloud init
   ```

3. **Authenticate**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

### Step 1: Set Up Environment Variables

Create `.env.production`:

```bash
# GCP Configuration
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="asia-south1"

# Database
export DB_INSTANCE="safar-nexus-db"
export DB_NAME="safar_nexus"
export DB_USER="safar_user"
export DB_PASSWORD="$(openssl rand -base64 32)"

# Storage
export GCS_BUCKET_NAME="safar-nexus-images-prod"

# Security
export JWT_SECRET_KEY="$(openssl rand -base64 32)"
```

Load environment:
```bash
source .env.production
```

### Step 2: Automated Deployment

**Option A: Use Deployment Script (Recommended)**

```bash
# Run automated deployment
./scripts/deploy-backend-gcp.sh
```

This script will:
- Enable required GCP APIs
- Build and push Docker image
- Create Cloud SQL instance
- Create Cloud Storage bucket
- Deploy to Cloud Run
- Output service URL

**Option B: Manual Deployment (Step by Step)**

See [Manual Deployment Steps](#manual-deployment-steps) below.

### Step 3: Enable PostGIS Extension

```bash
# Connect to Cloud SQL
gcloud sql connect $DB_INSTANCE --user=postgres

# Run in psql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
\q
```

### Step 4: Update Database Password

```bash
# Change postgres password
gcloud sql users set-password postgres \
  --instance=$DB_INSTANCE \
  --password="$DB_PASSWORD"

# Update Cloud Run with new password
gcloud run services update safar-nexus-api \
  --update-env-vars DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@/$DB_NAME?host=/cloudsql/<CONNECTION_NAME>" \
  --region=$GCP_REGION
```

### Step 5: Verify Deployment

```bash
# Get service URL
SERVICE_URL=$(gcloud run services describe safar-nexus-api \
  --region=$GCP_REGION \
  --format='value(status.url)')

echo "Service URL: $SERVICE_URL"

# Test health endpoint
curl $SERVICE_URL/health

# Test registration
curl -X POST $SERVICE_URL/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@safar-nexus.app","password":"SecurePass123","name":"Admin"}'
```

---

## Mobile App Deployment

### Prerequisites

- Flutter SDK installed
- Google Maps API key (Android + iOS)
- Backend deployed and URL obtained
- AI model (pothole_detector.tflite) downloaded

### Step 1: Configure Backend URL

Update `mobile_app/lib/utils/constants.dart`:

```dart
const String API_BASE_URL = "https://safar-nexus-api-xxx-uc.a.run.app";
```

### Step 2: Add Google Maps API Keys

**Android** - `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY_HERE"/>
```

**iOS** - `ios/Runner/Info.plist`:
```xml
<key>GMSApiKey</key>
<string>YOUR_IOS_API_KEY_HERE</string>
```

### Step 3: Add AI Model

```bash
# Place model file
cp /path/to/pothole_detector.tflite mobile_app/assets/models/
```

### Step 4: Build Apps

**Option A: Use Build Script**

```bash
./scripts/build-mobile.sh
# Select build option from menu
```

**Option B: Manual Build**

**Android APK:**
```bash
cd mobile_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (requires macOS):**
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

### Step 5: Test on Device

1. Install APK on Android device
2. Grant camera and location permissions
3. Test registration/login
4. Test camera detection (will show placeholder until model loaded)
5. Test map view

### Step 6: Distribute

**For Testing:**
- Share APK directly
- Use Firebase App Distribution

**For Production:**
- **Android**: Upload AAB to Google Play Console
- **iOS**: Submit to App Store via Xcode

---

## CI/CD Setup

### GitHub Actions Pipeline

The repository includes a complete CI/CD pipeline (`.github/workflows/ci-cd.yml`).

### Step 1: Add GitHub Secrets

Go to GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

```
GCP_PROJECT_ID          # Your GCP project ID
GCP_SA_KEY              # Service account JSON key (entire content)
DATABASE_URL            # PostgreSQL connection string
JWT_SECRET_KEY          # JWT secret (32+ characters)
GCS_BUCKET_NAME         # Cloud Storage bucket name
CLOUD_SQL_CONNECTION    # Cloud SQL connection name (project:region:instance)
```

### Step 2: Create Service Account for CI/CD

```bash
# Create service account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions"

# Grant permissions
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Generate key
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com

# Copy content of github-actions-key.json to GCP_SA_KEY secret
cat github-actions-key.json
```

### Step 3: Enable Workflows

Push to `main` branch to trigger:
- Backend tests
- Backend build & push to Container Registry
- Backend deployment to Cloud Run
- Mobile app build (Android APK artifact)

---

## Manual Deployment Steps

If you prefer manual deployment without scripts:

### 1. Enable APIs

```bash
gcloud services enable \
  run.googleapis.com \
  sqladmin.googleapis.com \
  storage.googleapis.com \
  cloudbuild.googleapis.com
```

### 2. Build and Push Image

```bash
cd backend
docker build -t gcr.io/$GCP_PROJECT_ID/safar-nexus-backend .
docker push gcr.io/$GCP_PROJECT_ID/safar-nexus-backend
```

### 3. Create Cloud SQL Instance

```bash
gcloud sql instances create safar-nexus-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=asia-south1 \
  --root-password="YOUR_SECURE_PASSWORD"

gcloud sql databases create safar_nexus --instance=safar-nexus-db
```

### 4. Create Storage Bucket

```bash
gsutil mb -p $GCP_PROJECT_ID -c STANDARD -l asia-south1 gs://safar-nexus-images-prod/
```

### 5. Deploy to Cloud Run

```bash
gcloud run deploy safar-nexus-api \
  --image gcr.io/$GCP_PROJECT_ID/safar-nexus-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-env-vars DATABASE_URL="YOUR_DB_URL",JWT_SECRET_KEY="YOUR_SECRET",GCS_BUCKET_NAME="safar-nexus-images-prod" \
  --add-cloudsql-instances $GCP_PROJECT_ID:asia-south1:safar-nexus-db
```

---

## Post-Deployment Checklist

### Backend Verification

- [ ] Health endpoint responds: `GET /health`
- [ ] API docs accessible: `GET /docs`
- [ ] User registration works
- [ ] User login works
- [ ] Database connection successful
- [ ] PostGIS extension enabled
- [ ] Cloud Storage uploads work

### Mobile App Verification

- [ ] Backend URL configured
- [ ] Google Maps API keys set
- [ ] Camera permission granted
- [ ] Location permission granted
- [ ] Login/Register works
- [ ] Map loads with markers
- [ ] GPS location acquired

### Security Checklist

- [ ] JWT secret key changed from default
- [ ] Database password changed from default
- [ ] Service account permissions minimal
- [ ] HTTPS enabled (automatic on Cloud Run)
- [ ] Sensitive data in .gitignore
- [ ] Environment variables not hardcoded

### Performance Checklist

- [ ] Cloud Run auto-scaling configured
- [ ] Database connection pooling enabled
- [ ] Image upload size limits enforced
- [ ] API rate limiting considered (future)
- [ ] CDN for images considered (future)

---

## Troubleshooting

### Backend Issues

**"Database connection failed"**
- Check Cloud SQL instance is running
- Verify connection name in environment variables
- Check Cloud Run service has Cloud SQL connection

**"Permission denied on storage"**
- Verify service account has Storage Admin role
- Check GCS bucket name is correct
- Verify GOOGLE_APPLICATION_CREDENTIALS set

### Mobile App Issues

**"Network error" when calling API**
- Verify backend URL is correct
- Check HTTPS (required on Android 9+)
- Test backend URL in browser first

**"Camera not working"**
- Check permissions granted in device settings
- Verify AndroidManifest.xml has camera permission
- Test on physical device (emulator camera limited)

**"Map not showing"**
- Verify Google Maps API key is valid
- Check API key has Maps SDK enabled
- Verify billing enabled on GCP project

---

## Cost Estimation

### Google Cloud (Monthly)

**Minimal Usage (MVP Testing):**
- Cloud Run: $0 (free tier: 2M requests/month)
- Cloud SQL (db-f1-micro): ~$10/month
- Cloud Storage: ~$1/month (first 5GB free)
- **Total: ~$11/month**

**Moderate Usage (100-1000 users):**
- Cloud Run: ~$20/month
- Cloud SQL (db-g1-small): ~$50/month
- Cloud Storage: ~$5/month
- **Total: ~$75/month**

**Production (10,000+ users):**
- Cloud Run: ~$100/month
- Cloud SQL (db-n1-standard-1): ~$150/month
- Cloud Storage: ~$20/month
- **Total: ~$270/month**

### Tips to Reduce Costs

- Use Cloud Run auto-scaling (scale to zero)
- Enable Cloud SQL auto-pause
- Set image retention policy on GCS
- Use CDN for frequently accessed images

---

## Monitoring & Logging

### View Logs

```bash
# Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Cloud SQL logs
gcloud sql operations list --instance=safar-nexus-db
```

### Set Up Alerts

```bash
# Create alert for high error rate
gcloud alpha monitoring policies create \
  --notification-channels=YOUR_CHANNEL_ID \
  --display-name="High Error Rate" \
  --condition-threshold-value=10 \
  --condition-threshold-duration=60s
```

---

## Backup & Recovery

### Database Backups

```bash
# Enable automated backups
gcloud sql instances patch safar-nexus-db \
  --backup-start-time=03:00

# Manual backup
gcloud sql backups create --instance=safar-nexus-db
```

### Storage Backups

```bash
# Enable versioning
gsutil versioning set on gs://safar-nexus-images-prod/
```

---

## Scaling Strategy

### Backend Scaling

```bash
# Configure Cloud Run autoscaling
gcloud run services update safar-nexus-api \
  --min-instances=0 \
  --max-instances=100 \
  --concurrency=80
```

### Database Scaling

```bash
# Upgrade instance
gcloud sql instances patch safar-nexus-db \
  --tier=db-n1-standard-2
```

---

## Support

For deployment issues:
- Check logs: `gcloud logging read`
- Review GCP quotas: `gcloud compute project-info describe`
- Check service status: `gcloud run services describe safar-nexus-api`

---

**Last Updated:** November 2024
**Version:** 1.0.0 (MVP)
