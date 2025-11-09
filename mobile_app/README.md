# SAFAR-Nexus Mobile App

Flutter mobile application for real-time road hazard detection using on-device AI.

## Features

- **Real-time Detection**: Camera-based pothole detection using YOLOv11 TensorFlow Lite model
- **GPS Tagging**: Automatic GPS coordinates for detected hazards
- **Instant Upload**: Background upload to backend with privacy blurring
- **Map View**: Visualize nearby hazards on Google Maps
- **Offline Support**: Queue detections when offline, auto-upload when connected
- **User Authentication**: Secure JWT-based authentication

## Tech Stack

- **Framework**: Flutter 3.0+
- **AI/ML**: TensorFlow Lite (YOLOv11 for pothole detection)
- **Camera**: camera package for frame capture
- **Maps**: google_maps_flutter for hazard visualization
- **Location**: geolocator for GPS tagging
- **Storage**: shared_preferences for local data
- **Networking**: http for API communication

## Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio / Xcode
- Google Maps API key (for Android and iOS)
- Pothole detection model (.tflite file)

## Setup

### 1. Install Flutter

Follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Base URL

Edit `lib/utils/constants.dart`:

```dart
const String API_BASE_URL = "https://your-api-url.app";  // Update with your backend URL
```

### 4. Add Google Maps API Key

**For Android:**

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

**For iOS:**

Edit `ios/Runner/Info.plist`:

```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

Also update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 5. Add AI Model

Place your trained `pothole_detector.tflite` model in:

```
assets/models/pothole_detector.tflite
```

The model should be a YOLOv11 model converted to TensorFlow Lite format.

**To acquire/train the model:**

- Option 1: Download pre-trained model from Roboflow Universe (search "pothole detection")
- Option 2: Train custom YOLOv11 model and convert to .tflite

**Model conversion example:**

```bash
# Export YOLO to ONNX
yolo export model=yolov11n.pt format=onnx

# Convert ONNX to TensorFlow
onnx-tf convert -i yolov11n.onnx -o yolov11n_tf

# Convert to TFLite
tflite_convert --saved_model_dir=yolov11n_tf \
  --output_file=pothole_detector.tflite \
  --optimizations=DEFAULT
```

## Running the App

### Android

```bash
flutter run
```

### iOS

```bash
flutter run
```

### Release Build

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure

```
mobile_app/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   │   ├── user.dart
│   │   └── hazard.dart
│   ├── services/              # Business logic
│   │   ├── ai_service.dart    # TFLite inference
│   │   ├── api_service.dart   # Backend API calls
│   │   ├── auth_service.dart  # Authentication
│   │   ├── location_service.dart  # GPS handling
│   │   └── storage_service.dart   # Local storage
│   ├── screens/               # UI screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── camera_screen.dart
│   │   └── map_screen.dart
│   ├── widgets/               # Reusable UI components
│   │   ├── detection_overlay.dart
│   │   └── stats_panel.dart
│   └── utils/                 # Helper utilities
│       ├── constants.dart
│       └── image_utils.dart
├── assets/
│   └── models/
│       └── pothole_detector.tflite
├── android/
├── ios/
└── pubspec.yaml
```

## Usage

1. **Register/Login**: Create account or login with existing credentials
2. **Grant Permissions**: Allow camera and location access when prompted
3. **Start Detection**: Camera automatically starts analyzing for potholes
4. **View Map**: Switch to Map tab to see all detected hazards
5. **Automatic Upload**: Detections are uploaded automatically in background

## Configuration

Key configuration in `lib/utils/constants.dart`:

```dart
const String API_BASE_URL = "https://api.safar-nexus.app";
const double CONFIDENCE_THRESHOLD = 0.7;  // Minimum detection confidence
const int PROCESS_EVERY_N_FRAMES = 3;     // Process every 3rd frame
const double DUPLICATE_DISTANCE_METERS = 10.0;  // Duplicate detection radius
```

## Troubleshooting

**Camera not working:**
- Check permissions are granted in device settings
- Ensure AndroidManifest.xml / Info.plist have camera permissions

**GPS not working:**
- Check location permissions are granted
- Enable location services on device
- Wait a few seconds for GPS signal

**AI model not loading:**
- Ensure .tflite file is in `assets/models/`
- Check `pubspec.yaml` includes the asset path
- Run `flutter clean` and rebuild

**Map not showing:**
- Verify Google Maps API key is correct
- Enable Maps SDK for Android/iOS in Google Cloud Console
- Check internet connection

## Performance

- **Target FPS**: 10-20 FPS (processing every 3rd frame at 30 FPS camera)
- **Inference Time**: <50ms on mid-range devices
- **Memory Usage**: <200MB
- **Battery Impact**: Moderate (continuous camera + AI processing)

## Future Enhancements

- On-device privacy blurring (currently done on backend)
- Sensor fusion (accelerometer + audio detection)
- Real-time alerts to nearby drivers
- Social verification of hazards
- Offline mode with better queue management

## License

MIT
