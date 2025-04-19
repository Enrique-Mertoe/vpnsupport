import os
import shutil
from dotenv import load_dotenv
from config import Config


def setup_development_environment():
    """Set up the development environment with necessary directories and files."""
    # Load environment variables
    load_dotenv()

    # Create development certificates directory
    os.makedirs(Config.VPN_CLIENT_DIR, exist_ok=True)

    # Create hotspot templates directory
    os.makedirs(Config.HOTSPOT_TEMPLATE_DIR, exist_ok=True)

    print("Development environment setup complete!")
    print("\nTo run the application in development mode:")
    print("1. Make sure your .env file is properly configured")
    print("2. Run: python app.py")
    print("\nFor dual network setup with Mikrotik:")
    print("1. Connect Mikrotik to your PC via Ethernet")
    print("2. Keep your WiFi connection active for internet")
    print("3. Configure network priorities in Windows Network Settings")
    print("\nCurrent configuration:")
    print(f"Environment: {Config.ENV}")
    print(f"VPN Host: {Config.VPN_HOST}")
    print(f"VPN Port: {Config.VPN_PORT}")
    print(f"Client Directory: {Config.VPN_CLIENT_DIR}")


if __name__ == "__main__":
    setup_development_environment()