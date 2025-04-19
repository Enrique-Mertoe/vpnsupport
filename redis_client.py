import redis
import os
from config import Config

def get_redis_client():
    """Get a Redis client instance."""
    try:
        redis_url = os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')
        return redis.from_url(redis_url, decode_responses=True)
    except Exception as e:
        raise Exception(f"Failed to connect to Redis: {str(e)}")

# Initialize Redis client
redis_client = get_redis_client() 