#!/bin/bash

# SAFAR-Nexus FREE Deployment Script
# Uses 100% FREE services - No credit card required!

set -e

echo "=========================================="
echo "🎉 SAFAR-Nexus FREE Deployment"
echo "=========================================="
echo "Using 100% FREE services:"
echo "  • Railway (Backend hosting - FREE tier)"
echo "  • Neon (PostgreSQL + PostGIS - FREE tier)"
echo "  • Cloudinary (Image storage - FREE tier)"
echo ""
echo "No credit card required! ✨"
echo "=========================================="
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm i -g @railway/cli || {
        echo "❌ Failed to install Railway CLI"
        echo "Please install manually: npm i -g @railway/cli"
        exit 1
    }
fi

echo "✅ Railway CLI installed"
echo ""

# Login to Railway
echo "🔐 Logging in to Railway..."
echo "This will open a browser window to authenticate."
railway login

echo ""
echo "✅ Logged in to Railway"
echo ""

# Initialize Railway project
echo "🚀 Creating Railway project..."
cd backend

if [ ! -f "railway.json" ]; then
    railway init
fi

echo ""
echo "📝 Configuring environment variables..."
echo ""

# Generate secrets
JWT_SECRET=$(openssl rand -base64 32)

echo "Please provide the following FREE service credentials:"
echo ""

# Neon Database (FREE PostgreSQL with PostGIS)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  NEON DATABASE (FREE PostgreSQL + PostGIS)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sign up at: https://neon.tech (FREE, no credit card)"
echo "  • Create a new project"
echo "  • Get your connection string"
echo "  • PostGIS is automatically available!"
echo ""
read -p "Enter Neon PostgreSQL connection string: " DATABASE_URL
echo ""

# Cloudinary (FREE image storage)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  CLOUDINARY (FREE Image Storage)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sign up at: https://cloudinary.com (FREE tier: 25GB storage)"
echo "  • Go to Dashboard"
echo "  • Copy: Cloud Name, API Key, API Secret"
echo ""
read -p "Enter Cloudinary Cloud Name: " CLOUDINARY_CLOUD_NAME
read -p "Enter Cloudinary API Key: " CLOUDINARY_API_KEY
read -p "Enter Cloudinary API Secret: " CLOUDINARY_API_SECRET
echo ""

# Set environment variables on Railway
echo "🔧 Setting environment variables on Railway..."

railway variables set DATABASE_URL="$DATABASE_URL"
railway variables set JWT_SECRET_KEY="$JWT_SECRET"
railway variables set CLOUDINARY_CLOUD_NAME="$CLOUDINARY_CLOUD_NAME"
railway variables set CLOUDINARY_API_KEY="$CLOUDINARY_API_KEY"
railway variables set CLOUDINARY_API_SECRET="$CLOUDINARY_API_SECRET"
railway variables set USE_CLOUDINARY="true"

echo "✅ Environment variables set"
echo ""

# Deploy to Railway
echo "🚀 Deploying to Railway..."
railway up

echo ""
echo "⏳ Waiting for deployment..."
sleep 10

# Get deployment URL
RAILWAY_URL=$(railway domain)

cd ..

echo ""
echo "=========================================="
echo "🎉 DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "✅ Backend deployed to Railway (FREE)"
echo "✅ Database on Neon (FREE)"
echo "✅ Storage on Cloudinary (FREE)"
echo ""
echo "🌐 Your API URL:"
echo "   $RAILWAY_URL"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Test your API:"
echo "   curl $RAILWAY_URL/health"
echo ""
echo "2. Enable PostGIS on Neon:"
echo "   - Go to Neon dashboard > SQL Editor"
echo "   - Run: CREATE EXTENSION IF NOT EXISTS postgis;"
echo ""
echo "3. Update mobile app:"
echo "   - Edit: mobile_app/lib/utils/constants.dart"
echo "   - Set: const String API_BASE_URL = \"$RAILWAY_URL\";"
echo ""
echo "4. Test API docs:"
echo "   - Visit: $RAILWAY_URL/docs"
echo ""
echo "💰 Monthly Cost: $0 (100% FREE!)"
echo ""
echo "🎉 No credit card required!"
echo "=========================================="
