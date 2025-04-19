from config_manager import config


class Config:
    """Application configuration class."""

    # Flask Configuration
    SECRET_KEY = config.get('SECRET_KEY', 'default-secret-key')
    JWT_SECRET_KEY = config.get('JWT_SECRET_KEY', 'default-jwt-secret')

    # Redis Configuration
    REDIS_HOST = config.get('REDIS_HOST', 'localhost')
    REDIS_PORT = config.get_int('REDIS_PORT', 6379)
    CELERY_BROKER_URL = config.get('CELERY_BROKER_URL', 'redis://localhost:6379/0')
    CELERY_RESULT_BACKEND = config.get('CELERY_RESULT_BACKEND', 'redis://localhost:6379/0')

    # OpenVPN Configuration
    VPN_HOST = config.get('VPN_HOST', 'localhost')
    VPN_PORT = config.get_int('VPN_PORT', 1194)
    VPN_CLIENT_DIR = config.get('VPN_CLIENT_DIR', './dev_certs')

    # Hotspot Configuration
    HOTSPOT_TEMPLATE_DIR = config.get('HOTSPOT_TEMPLATE_DIR', './templates')

    # Logging Configuration
    LOG_LEVEL = config.get('LOG_LEVEL', 'INFO')

    @classmethod
    def is_development(cls):
        """Check if running in development environment."""
        return config.is_development

    @classmethod
    def is_production(cls):
        """Check if running in production environment."""
        return config.is_production

    # Environment
    ENV = config.get('FLASK_ENV', 'production')
    IS_DEVELOPMENT = ENV == 'development'

    # Security
    ALLOWED_PROVISION_IDENTITY_PATTERN = r'^[a-zA-Z0-9_-]+$'

    # API Settings
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB max file size 