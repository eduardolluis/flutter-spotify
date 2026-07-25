import os
from pathlib import Path

from dotenv import load_dotenv


load_dotenv(Path(__file__).resolve().parent / ".env")


def required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


DATABASE_URL = required_env("DATABASE_URL")
JWT_SECRET = required_env("JWT_SECRET")
CLOUDINARY_CLOUD_NAME = required_env("CLOUDINARY_CLOUD_NAME")
CLOUDINARY_API_KEY = required_env("CLOUDINARY_API_KEY")
CLOUDINARY_API_SECRET = required_env("CLOUDINARY_API_SECRET")
GOOGLE_WEB_CLIENT_ID = required_env("GOOGLE_WEB_CLIENT_ID")
