#!/bin/bash

# SAFAR-Nexus Backend Deployment Script for Google Cloud Run
# Prerequisites: gcloud CLI installed and authenticated

set -e  # Exit on error

# Configuration
PROJECT_ID=${GCP_PROJECT_ID:-"your-gcp-project-id"}
REGION=${GCP_REGION:-"asia-south1"}
SERVICE_NAME="safar-nexus-api"
IMAGE_NAME="safar-nexus-backend"

# Database Configuration
DB_INSTANCE=${DB_INSTANCE:-"safar-nexus-db"}
DB_NAME=${DB_NAME:-"safar_nexus"}
DB_USER=${DB_USER:-"safar_user"}

# Storage Configuration
BUCKET_NAME=${GCS_BUCKET_NAME:-"safar-nexus-images"}

# Secrets
JWT_SECRET_KEY=${JWT_SECRET_KEY:-""}

echo "=========================================="
echo "SAFAR-Nexus Backend Deployment to GCP"
echo "=========================================="
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Service: $SERVICE_NAME"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI not found. Please install it first."
    echo "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "Error: Not authenticated with gcloud. Please run: gcloud auth login"
    exit 1
fi

# Set project
echo "Setting GCP project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Enabling required GCP APIs..."
gcloud services enable \
    run.googleapis.com \
    sqladmin.googleapis.com \
    storage.googleapis.com \
    cloudbuild.googleapis.com \
    containerregistry.googleapis.com

# Build Docker image
echo ""
echo "Building Docker image..."
cd backend
docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:latest .
cd ..

# Push to Container Registry
echo ""
echo "Pushing image to Google Container Registry..."
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:latest

# Check if Cloud SQL instance exists
echo ""
echo "Checking Cloud SQL instance..."
if ! gcloud sql instances describe $DB_INSTANCE &> /dev/null; then
    echo "Cloud SQL instance not found. Creating..."
    gcloud sql instances create $DB_INSTANCE \
        --database-version=POSTGRES_15 \
        --tier=db-f1-micro \
        --region=$REGION \
        --root-password=$(openssl rand -base64 32)

    echo "Waiting for instance to be ready..."
    sleep 60
else
    echo "Cloud SQL instance already exists."
fi

# Create database
echo ""
echo "Creating database..."
gcloud sql databases create $DB_NAME --instance=$DB_INSTANCE || echo "Database may already exist"

# Enable PostGIS (requires connection to database)
echo ""
echo "PostGIS extension needs to be enabled manually via Cloud SQL proxy"
echo "Run: gcloud sql connect $DB_INSTANCE --user=postgres"
echo "Then: CREATE EXTENSION IF NOT EXISTS postgis;"
echo "      CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

# Check if Cloud Storage bucket exists
echo ""
echo "Checking Cloud Storage bucket..."
if ! gsutil ls -b gs://$BUCKET_NAME &> /dev/null; then
    echo "Creating Cloud Storage bucket..."
    gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$BUCKET_NAME/
    gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME/
else
    echo "Cloud Storage bucket already exists."
fi

# Create service account if not exists
SERVICE_ACCOUNT="safar-nexus-backend@$PROJECT_ID.iam.gserviceaccount.com"
echo ""
echo "Checking service account..."
if ! gcloud iam service-accounts describe $SERVICE_ACCOUNT &> /dev/null; then
    echo "Creating service account..."
    gcloud iam service-accounts create safar-nexus-backend \
        --display-name="SAFAR Nexus Backend Service Account"
fi

# Grant permissions
echo ""
echo "Granting permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/storage.objectAdmin" || true

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/cloudsql.client" || true

# Generate JWT secret if not provided
if [ -z "$JWT_SECRET_KEY" ]; then
    JWT_SECRET_KEY=$(openssl rand -base64 32)
    echo "Generated JWT secret key (save this!): $JWT_SECRET_KEY"
fi

# Get database connection string
CONNECTION_NAME=$(gcloud sql instances describe $DB_INSTANCE --format='value(connectionName)')
DATABASE_URL="postgresql://$DB_USER:PASSWORD@/$DB_NAME?host=/cloudsql/$CONNECTION_NAME"

# Deploy to Cloud Run
echo ""
echo "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image gcr.io/$PROJECT_ID/$IMAGE_NAME:latest \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --set-env-vars DATABASE_URL="$DATABASE_URL",JWT_SECRET_KEY="$JWT_SECRET_KEY",GCS_BUCKET_NAME="$BUCKET_NAME" \
    --add-cloudsql-instances $CONNECTION_NAME \
    --memory 1Gi \
    --cpu 1 \
    --timeout 60 \
    --service-account $SERVICE_ACCOUNT

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "Service URL: $SERVICE_URL"
echo "API Docs: $SERVICE_URL/docs"
echo "Health Check: $SERVICE_URL/health"
echo ""
echo "Database Connection: $CONNECTION_NAME"
echo "Storage Bucket: gs://$BUCKET_NAME"
echo ""
echo "IMPORTANT: Update mobile app with this API URL:"
echo "File: mobile_app/lib/utils/constants.dart"
echo "const String API_BASE_URL = \"$SERVICE_URL\";"
echo ""
echo "Next steps:"
echo "1. Connect to Cloud SQL and enable PostGIS extension"
echo "2. Update database password and connection string"
echo "3. Test API endpoints"
echo "4. Update mobile app with API URL"
echo "=========================================="
