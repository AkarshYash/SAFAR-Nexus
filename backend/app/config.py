from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Database (supports FREE options: Neon, Supabase, Railway PostgreSQL)
    DATABASE_URL: str

    # Authentication
    JWT_SECRET_KEY: str

    # Storage Backend Selection
    USE_CLOUDINARY: bool = False  # Set to True for FREE Cloudinary storage

    # Cloudinary (FREE tier: 25GB storage, no credit card required)
    CLOUDINARY_CLOUD_NAME: Optional[str] = None
    CLOUDINARY_API_KEY: Optional[str] = None
    CLOUDINARY_API_SECRET: Optional[str] = None

    # Google Cloud Storage (Original paid option)
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


# Run validation on import (but allow it to fail for easier development)
try:
    validate_storage_config()
except ValueError as e:
    print(f"⚠️  Storage config warning: {e}")
