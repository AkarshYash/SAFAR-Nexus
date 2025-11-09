"""
Storage Service - Supports both FREE (Cloudinary) and Paid (GCS) options
"""

from app.config import settings
import uuid


# Lazy import GCS only if needed (allows running without GCS credentials)
_gcs_client = None
_gcs_bucket = None


def _get_gcs_bucket():
    """Lazy initialize GCS client"""
    global _gcs_client, _gcs_bucket
    if _gcs_bucket is None:
        from google.cloud import storage
        _gcs_client = storage.Client()
        _gcs_bucket = _gcs_client.bucket(settings.GCS_BUCKET_NAME)
    return _gcs_bucket


def upload_to_gcs(image_bytes: bytes, filename: str) -> str:
    """
    Upload image to Google Cloud Storage (Paid option)
    Returns public URL of uploaded image
    """
    bucket = _get_gcs_bucket()
    blob = bucket.blob(f"hazards/{filename}")
    blob.upload_from_string(image_bytes, content_type='image/jpeg')

    # Make blob publicly readable (for MVP; use signed URLs in production)
    blob.make_public()

    return blob.public_url


def upload_to_cloudinary(image_bytes: bytes, filename: str) -> str:
    """
    Upload image to Cloudinary (FREE option - 25GB free)
    Returns public URL of uploaded image
    """
    from app.services.cloudinary_storage_service import upload_to_cloudinary as cloudinary_upload
    return cloudinary_upload(image_bytes, filename)


def upload_image(image_bytes: bytes, filename: str = None) -> str:
    """
    Upload image to configured storage backend
    Automatically routes to Cloudinary (FREE) or GCS based on USE_CLOUDINARY setting

    Args:
        image_bytes: Image data as bytes
        filename: Optional filename (UUID generated if not provided)

    Returns:
        Public URL of uploaded image
    """
    if filename is None:
        filename = f"{uuid.uuid4()}.jpg"

    if settings.USE_CLOUDINARY:
        # Use FREE Cloudinary storage
        return upload_to_cloudinary(image_bytes, filename)
    else:
        # Use Google Cloud Storage (paid)
        return upload_to_gcs(image_bytes, filename)
