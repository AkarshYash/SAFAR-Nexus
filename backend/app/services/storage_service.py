from google.cloud import storage
from app.config import settings
import uuid

# Initialize GCS client
client = storage.Client()
bucket = client.bucket(settings.GCS_BUCKET_NAME)


def upload_to_gcs(image_bytes: bytes, filename: str) -> str:
    """
    Upload image to Google Cloud Storage
    Returns public URL of uploaded image
    """
    blob = bucket.blob(f"hazards/{filename}")
    blob.upload_from_string(image_bytes, content_type='image/jpeg')

    # Make blob publicly readable (for MVP; use signed URLs in production)
    blob.make_public()

    return blob.public_url
