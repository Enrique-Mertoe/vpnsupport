import os
import time
import redis
from redis.exceptions import ConnectionError, RedisError
from config import Config

class RedisClient:
    def __init__(self, max_retries=3, retry_delay=1):
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self._client = None
        self._connect()

    def _connect(self):
        """Establish Redis connection with retry logic."""
        for attempt in range(self.max_retries):
            try:
                self._client = redis.Redis(
                    host=Config.REDIS_HOST,
                    port=Config.REDIS_PORT,
                    decode_responses=True,
                    socket_timeout=5,
                    socket_connect_timeout=5
                )
                # Test the connection
                self._client.ping()
                return
            except (ConnectionError, RedisError) as e:
                if attempt == self.max_retries - 1:
                    raise Exception(f"Failed to connect to Redis after {self.max_retries} attempts: {str(e)}")
                time.sleep(self.retry_delay)

    def get_client(self):
        """Get the Redis client instance."""
        if not self._client:
            self._connect()
        return self._client

    def ping(self):
        """Check if Redis is responsive."""
        try:
            return self.get_client().ping()
        except (ConnectionError, RedisError):
            return False

    def __getattr__(self, name):
        """Delegate unknown attributes to the Redis client."""
        if not self._client:
            self._connect()
        return getattr(self._client, name)

# Create a global Redis client instance
redis_client = RedisClient()