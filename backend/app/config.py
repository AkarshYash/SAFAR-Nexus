from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str
    JWT_SECRET_KEY: str
    GCS_BUCKET_NAME: str
    GOOGLE_APPLICATION_CREDENTIALS: str

    class Config:
        env_file = ".env"


settings = Settings()
