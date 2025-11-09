"""
Cloudinary Storage Service (FREE Alternative to Google Cloud Storage)

FREE Tier: 25GB storage, 25GB bandwidth/month
No credit card required!
"""

import cloudinary
import cloudinary.uploader
import cloudinary.api
from app.config import settings
import uuid


def initialize_cloudinary():
    """Initialize Cloudinary with credentials"""
    cloudinary.config(
        cloud_name=settings.CLOUDINARY_CLOUD_NAME,
        api_key=settings.CLOUDINARY_API_KEY,
        api_secret=settings.CLOUDINARY_API_SECRET,
        secure=True
    )


def upload_to_cloudinary(image_bytes: bytes, filename: str = None) -> str:
    """
    Upload image to Cloudinary (FREE tier)

    Args:
        image_bytes: Image data as bytes
        filename: Optional filename (UUID generated if not provided)

    Returns:
        Public URL of uploaded image
    """
    if filename is None:
        filename = f"{uuid.uuid4()}.jpg"

    # Initialize Cloudinary
    initialize_cloudinary()

    # Upload to Cloudinary
    # Folder: safar-nexus-hazards
    # Resource type: image
    # Overwrite: False (unique filenames)
    result = cloudinary.uploader.upload(
        image_bytes,
        folder="safar-nexus-hazards",
        public_id=filename.replace('.jpg', ''),
        resource_type="image",
        overwrite=False
    )

    # Return secure URL
    return result['secure_url']


def delete_from_cloudinary(public_id: str) -> bool:
    """
    Delete image from Cloudinary

    Args:
        public_id: Cloudinary public ID of the image

    Returns:
        True if successful, False otherwise
    """
    try:
        initialize_cloudinary()
        result = cloudinary.uploader.destroy(public_id)
        return result.get('result') == 'ok'
    except Exception as e:
        print(f"Error deleting from Cloudinary: {e}")
        return False


# Compatibility wrapper to match GCS interface
def upload_to_storage(image_bytes: bytes, filename: str) -> str:
    """
    Upload to appropriate storage based on configuration
    Supports both GCS and Cloudinary
    """
    use_cloudinary = getattr(settings, 'USE_CLOUDINARY', True)

    if use_cloudinary:
        return upload_to_cloudinary(image_bytes, filename)
    else:
        # Fallback to GCS if configured
        from app.services.storage_service import upload_to_gcs
        return upload_to_gcs(image_bytes, filename)
