# SAFAR-Nexus API Documentation

Base URL: `https://api.safar-nexus.app` (or your deployed Cloud Run URL)

## Authentication

All endpoints except authentication routes require JWT token in Authorization header:

```
Authorization: Bearer <jwt_token>
```

Tokens expire after 30 days (MVP setting).

---

## Authentication Endpoints

### Register User

Create a new user account.

**Endpoint:** `POST /api/v1/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepass123",
  "name": "John Doe"
}
```

**Validation:**
- Email: Valid email format
- Password: Minimum 8 characters
- Name: 1-100 characters

**Response:** `200 OK`
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "John Doe",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errors:**
- `400 Bad Request`: Email already registered or validation failed
- `500 Internal Server Error`: Server error

---

### Login User

Authenticate existing user.

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepass123"
}
```

**Response:** `200 OK`
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "John Doe",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errors:**
- `401 Unauthorized`: Invalid credentials
- `500 Internal Server Error`: Server error

---

## Hazard Endpoints

### Upload Hazard

Upload a detected hazard with image.

**Endpoint:** `POST /api/v1/hazards`

**Authentication:** Required

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `image` (file): JPEG image, max 5MB
- `latitude` (float): -90 to 90
- `longitude` (float): -180 to 180
- `confidence` (float): 0.0 to 1.0 (AI model confidence)
- `timestamp` (string): ISO 8601 format (e.g., "2024-01-15T10:30:00Z")
- `device_id` (string): UUID of device

**Example (cURL):**
```bash
curl -X POST "https://api.safar-nexus.app/api/v1/hazards" \
  -H "Authorization: Bearer <token>" \
  -F "image=@pothole.jpg" \
  -F "latitude=28.7041" \
  -F "longitude=77.1025" \
  -F "confidence=0.87" \
  -F "timestamp=2024-01-15T10:30:00Z" \
  -F "device_id=550e8400-e29b-41d4-a716-446655440001"
```

**Processing:**
1. Validates image and parameters
2. Applies privacy blurring (faces, license plates)
3. Uploads blurred image to Google Cloud Storage
4. Saves hazard record to database with PostGIS point
5. Returns hazard ID

**Response:** `200 OK`
```json
{
  "hazard_id": "660e8400-e29b-41d4-a716-446655440002",
  "status": "success",
  "blurred_image_url": "https://storage.googleapis.com/safar-nexus-images/hazards/660e8400.jpg",
  "created_at": "2024-01-15T10:30:05.123Z"
}
```

**Errors:**
- `401 Unauthorized`: Invalid or missing token
- `400 Bad Request`: Invalid parameters (e.g., latitude out of range)
- `413 Payload Too Large`: Image exceeds 5MB
- `500 Internal Server Error`: Processing or storage failure

---

### Get Nearby Hazards

Retrieve hazards within a radius of a location.

**Endpoint:** `GET /api/v1/hazards/nearby`

**Authentication:** Required

**Query Parameters:**
- `latitude` (float, required): Center latitude
- `longitude` (float, required): Center longitude
- `radius_km` (float, optional): Search radius in km (default: 5, max: 50)
- `limit` (int, optional): Max results (default: 100, max: 500)

**Example:**
```bash
curl "https://api.safar-nexus.app/api/v1/hazards/nearby?latitude=28.7041&longitude=77.1025&radius_km=10&limit=50" \
  -H "Authorization: Bearer <token>"
```

**Spatial Query:**
Uses PostGIS `ST_DWithin` for efficient geographic filtering. Results are sorted by distance (nearest first).

**Response:** `200 OK`
```json
{
  "hazards": [
    {
      "hazard_id": "660e8400-e29b-41d4-a716-446655440002",
      "latitude": 28.7050,
      "longitude": 77.1030,
      "confidence": 0.87,
      "timestamp": "2024-01-15T10:30:00Z",
      "distance_km": 0.12,
      "image_url": "https://storage.googleapis.com/safar-nexus-images/hazards/660e8400.jpg"
    },
    {
      "hazard_id": "770e8400-e29b-41d4-a716-446655440003",
      "latitude": 28.7100,
      "longitude": 77.1100,
      "confidence": 0.92,
      "timestamp": "2024-01-15T09:15:00Z",
      "distance_km": 0.85,
      "image_url": "https://storage.googleapis.com/safar-nexus-images/hazards/770e8400.jpg"
    }
  ]
}
```

**Errors:**
- `401 Unauthorized`: Invalid or missing token
- `400 Bad Request`: Invalid coordinates or radius exceeds max
- `500 Internal Server Error`: Database error

---

### Get Hazard Details

Retrieve details for a specific hazard.

**Endpoint:** `GET /api/v1/hazards/{hazard_id}`

**Authentication:** Required

**Path Parameters:**
- `hazard_id` (UUID): Hazard identifier

**Example:**
```bash
curl "https://api.safar-nexus.app/api/v1/hazards/660e8400-e29b-41d4-a716-446655440002" \
  -H "Authorization: Bearer <token>"
```

**Response:** `200 OK`
```json
{
  "hazard_id": "660e8400-e29b-41d4-a716-446655440002",
  "latitude": 28.7050,
  "longitude": 77.1030,
  "confidence": 0.87,
  "timestamp": "2024-01-15T10:30:00Z",
  "image_url": "https://storage.googleapis.com/safar-nexus-images/hazards/660e8400.jpg",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "device_id": "550e8400-e29b-41d4-a716-446655440001"
}
```

**Errors:**
- `401 Unauthorized`: Invalid or missing token
- `404 Not Found`: Hazard ID doesn't exist
- `500 Internal Server Error`: Database error

---

## Health Endpoints

### Root

API information.

**Endpoint:** `GET /`

**Response:** `200 OK`
```json
{
  "message": "SAFAR-Nexus API",
  "version": "1.0.0"
}
```

---

### Health Check

Service health status.

**Endpoint:** `GET /health`

**Response:** `200 OK`
```json
{
  "status": "healthy"
}
```

---

## Error Responses

All errors follow this format:

```json
{
  "detail": "Error message describing what went wrong"
}
```

**Common HTTP Status Codes:**
- `200 OK`: Success
- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Authentication required or failed
- `404 Not Found`: Resource not found
- `413 Payload Too Large`: Request body too large
- `500 Internal Server Error`: Server-side error

---

## Rate Limiting

**MVP:** No rate limiting implemented.

**Production Recommendation:**
- 100 uploads per user per hour
- 1000 API requests per user per hour
- Return `429 Too Many Requests` when exceeded

---

## Data Types

### UUID Format
Standard UUID v4: `550e8400-e29b-41d4-a716-446655440000`

### Timestamp Format
ISO 8601 UTC: `2024-01-15T10:30:00Z` or `2024-01-15T10:30:00.123Z`

### Coordinates
- Latitude: Float, -90 to 90 (negative = South, positive = North)
- Longitude: Float, -180 to 180 (negative = West, positive = East)

### Confidence
Float between 0.0 and 1.0 representing AI model confidence (0.0 = 0%, 1.0 = 100%)

---

## Privacy & Security

### Privacy Blurring
All uploaded images are automatically processed to blur:
- Faces (using Haar Cascade face detection)
- License plates (planned feature)

Original unblurred images are not stored.

### Authentication
- JWT tokens with HS256 algorithm
- Tokens expire after 30 days (configurable)
- Passwords hashed with bcrypt (cost factor 12)

### HTTPS
All API communication must use HTTPS in production.

---

## Interactive Documentation

Visit `/docs` on the running API server for interactive Swagger UI documentation where you can test endpoints directly.

Example: `https://api.safar-nexus.app/docs`

---

## SDK / Client Libraries

**Mobile App:**
The Flutter app includes built-in API client (`ApiService` class).

**Custom Integration:**
Use any HTTP client library. Example with Python `requests`:

```python
import requests

# Login
response = requests.post(
    "https://api.safar-nexus.app/api/v1/auth/login",
    json={"email": "user@example.com", "password": "pass123"}
)
token = response.json()["token"]

# Upload hazard
files = {"image": open("pothole.jpg", "rb")}
data = {
    "latitude": 28.7041,
    "longitude": 77.1025,
    "confidence": 0.87,
    "timestamp": "2024-01-15T10:30:00Z",
    "device_id": "550e8400-e29b-41d4-a716-446655440001"
}
headers = {"Authorization": f"Bearer {token}"}

response = requests.post(
    "https://api.safar-nexus.app/api/v1/hazards",
    files=files,
    data=data,
    headers=headers
)
print(response.json())
```

---

## Support

For API issues or questions:
- Check interactive docs: `/docs`
- Review backend README: `backend/README.md`
- Open GitHub issue

## Changelog

**v1.0.0** (MVP)
- User registration and authentication
- Hazard upload with image
- Privacy blurring (faces)
- Nearby hazard retrieval with PostGIS
- Google Cloud Storage integration
