from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    DATABASE_URL: str
    REDIS_URL: str = "redis://redis:6379/0"
    CORS_ORIGINS: str = "*"
    VOTE_THRESHOLD: int = 25
    GEMINI_API_KEY: str = ""  # Will be set via environment variable
    
    # Postgres variables (for docker-compose)
    POSTGRES_DB: str = "factual"
    POSTGRES_USER: str = "factual" 
    POSTGRES_PASSWORD: str = "secret"
    
    # Admin Auth
    JWT_SECRET: str = "change-me-in-production"
    ADMIN_PASS_SHA256: str = ""

    class Config:
        env_file = ".env"

settings = Settings()

def cors_origins_list() -> List[str]:
    return [o.strip() for o in settings.CORS_ORIGINS.split(',') if o.strip()]
