import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Config:
    # Environment
    ENV = os.getenv('FLASK_ENV', 'production')
    IS_DEVELOPMENT = ENV == 'development'

    # OpenVPN Configuration
    VPN_HOST = os.getenv('VPN_HOST', '34.45.7.160')
    VPN_PORT = int(os.getenv('VPN_PORT', '1194'))
    VPN_CLIENT_DIR = os.getenv('VPN_CLIENT_DIR',
                               os.path.join(os.path.dirname(__file__), "dev_certs") if IS_DEVELOPMENT
                               else "/etc/openvpn/clients")
    VPN_CA_CERT = os.path.join(VPN_CLIENT_DIR, "ca.crt")
    VPN_TLS_CRYPT = os.path.join(VPN_CLIENT_DIR, "tls-crypt.key")

    # Hotspot Configuration
    HOTSPOT_TEMPLATE_DIR = os.path.join(os.path.dirname(__file__), "hotspot_templates")

    # Security
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key' if IS_DEVELOPMENT else 'your-secret-key-here')
    ALLOWED_PROVISION_IDENTITY_PATTERN = r'^[a-zA-Z0-9_-]+$'

    # API Settings
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB max file size