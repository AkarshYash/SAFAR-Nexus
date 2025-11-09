"""
Configuration for FREE deployment
Supports multiple FREE-tier services
"""

from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Database (FREE options: Neon, Supabase, Railway PostgreSQL)
    DATABASE_URL: str

    # Authentication
    JWT_SECRET_KEY: str

    # Storage Backend Selection
    USE_CLOUDINARY: bool = True  # Use Cloudinary (FREE) instead of GCS

    # Cloudinary (FREE tier: 25GB storage)
    CLOUDINARY_CLOUD_NAME: Optional[str] = None
    CLOUDINARY_API_KEY: Optional[str] = None
    CLOUDINARY_API_SECRET: Optional[str] = None

    # Google Cloud Storage (Optional - only if not using Cloudinary)
    GCS_BUCKET_NAME: Optional[str] = None
    GOOGLE_APPLICATION_CREDENTIALS: Optional[str] = None

    class Config:
        env_file = ".env"


settings = Settings()


# Validate configuration
def validate_storage_config():
    """Ensure at least one storage backend is configured"""
    if settings.USE_CLOUDINARY:
        if not all([
            settings.CLOUDINARY_CLOUD_NAME,
            settings.CLOUDINARY_API_KEY,
            settings.CLOUDINARY_API_SECRET
        ]):
            raise ValueError(
                "Cloudinary credentials missing! "
                "Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET"
            )
    else:
        if not settings.GCS_BUCKET_NAME:
            raise ValueError("GCS_BUCKET_NAME required when not using Cloudinary")


# Run validation on import
try:
    validate_storage_config()
except ValueError as e:
    print(f"⚠️  Warning: {e}")
