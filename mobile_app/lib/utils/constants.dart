// API Configuration
const String API_BASE_URL = "https://api.safar-nexus.app";  // Update with actual Cloud Run URL

// Detection Thresholds
const double CONFIDENCE_THRESHOLD = 0.7;
const double IOU_THRESHOLD = 0.45;

// Upload Settings
const int MAX_IMAGE_SIZE_MB = 5;
const int MAX_QUEUE_SIZE = 100;

// Duplicate Detection
const double DUPLICATE_DISTANCE_METERS = 10.0;
const int DUPLICATE_TIME_SECONDS = 30;

// Map Settings
const double DEFAULT_MAP_ZOOM = 15.0;
const double NEARBY_RADIUS_KM = 5.0;

// UI Constants
const int TOAST_DURATION_SECONDS = 2;
const int PROCESS_EVERY_N_FRAMES = 3;
