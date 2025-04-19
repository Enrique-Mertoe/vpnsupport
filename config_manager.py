import os
from pathlib import Path
from dotenv import load_dotenv

class ConfigManager:
    def __init__(self):
        self.env = os.getenv('FLASK_ENV', 'development')
        self.base_dir = Path(__file__).parent
        self._load_env()

    def _load_env(self):
        """Load environment variables based on the current environment."""
        # Load base .env file
        base_env_path = self.base_dir / '.env'
        if base_env_path.exists():
            load_dotenv(base_env_path)

        # Load environment-specific .env file
        env_file = f'.env.{self.env}'
        env_path = self.base_dir / env_file
        if env_path.exists():
            load_dotenv(env_path, override=True)

    def get(self, key, default=None):
        """Get a configuration value."""
        return os.getenv(key, default)

    def get_bool(self, key, default=False):
        """Get a boolean configuration value."""
        value = self.get(key, str(default))
        return value.lower() in ('true', '1', 'yes')

    def get_int(self, key, default=0):
        """Get an integer configuration value."""
        try:
            return int(self.get(key, default))
        except (ValueError, TypeError):
            return default

    def get_float(self, key, default=0.0):
        """Get a float configuration value."""
        try:
            return float(self.get(key, default))
        except (ValueError, TypeError):
            return default

    @property
    def is_development(self):
        """Check if running in development environment."""
        return self.env == 'development'

    @property
    def is_production(self):
        """Check if running in production environment."""
        return self.env == 'production'

# Create a global config instance
config = ConfigManager() 