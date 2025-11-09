#!/bin/bash

# Mobile App Build Script
# Builds Android APK and iOS IPA

set -e

echo "=========================================="
echo "SAFAR-Nexus Mobile App Build"
echo "=========================================="

# Check Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter not found. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

cd mobile_app

# Check Flutter version
echo "Flutter version:"
flutter --version

# Get dependencies
echo ""
echo "Installing dependencies..."
flutter pub get

# Run analysis
echo ""
echo "Running Flutter analysis..."
flutter analyze || echo "Warning: Analysis found issues"

# Check configuration
echo ""
echo "Checking configuration..."

# Check API URL
if grep -q "https://api.safar-nexus.app" lib/utils/constants.dart; then
    echo "Warning: Using default API URL. Update in lib/utils/constants.dart"
fi

# Check Google Maps API key in Android
if grep -q "YOUR_GOOGLE_MAPS_API_KEY_HERE" android/app/src/main/AndroidManifest.xml; then
    echo "Warning: Google Maps API key not set in Android manifest"
fi

# Check AI model
if [ ! -f assets/models/pothole_detector.tflite ]; then
    echo "Warning: AI model not found at assets/models/pothole_detector.tflite"
    echo "App will run but detection won't work"
fi

# Build options
echo ""
echo "Build options:"
echo "1) Android APK (debug)"
echo "2) Android APK (release)"
echo "3) Android AAB (release - for Play Store)"
echo "4) iOS (requires macOS)"
echo "5) All Android builds"
read -p "Select option [1-5]: " BUILD_OPTION

case $BUILD_OPTION in
    1)
        echo ""
        echo "Building Android APK (debug)..."
        flutter build apk --debug
        echo "APK location: build/app/outputs/flutter-apk/app-debug.apk"
        ;;
    2)
        echo ""
        echo "Building Android APK (release)..."
        flutter build apk --release
        echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo ""
        echo "Building Android App Bundle (release)..."
        flutter build appbundle --release
        echo "AAB location: build/app/outputs/bundle/release/app-release.aab"
        ;;
    4)
        if [[ "$OSTYPE" != "darwin"* ]]; then
            echo "Error: iOS builds require macOS"
            exit 1
        fi
        echo ""
        echo "Building iOS..."
        flutter build ios --release
        echo "iOS build complete. Open ios/Runner.xcworkspace in Xcode to archive."
        ;;
    5)
        echo ""
        echo "Building all Android variants..."
        flutter build apk --debug
        flutter build apk --release
        flutter build appbundle --release
        echo ""
        echo "All builds complete:"
        echo "  Debug APK: build/app/outputs/flutter-apk/app-debug.apk"
        echo "  Release APK: build/app/outputs/flutter-apk/app-release.apk"
        echo "  Release AAB: build/app/outputs/bundle/release/app-release.aab"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

cd ..

echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "Before distributing:"
echo "1. Test on physical device"
echo "2. Verify API connection works"
echo "3. Test camera permissions"
echo "4. Test GPS location"
echo "5. Verify Google Maps loads"
echo "=========================================="
