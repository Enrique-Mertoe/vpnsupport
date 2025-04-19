import os
import subprocess
import logging
from celery_config import celery
from helper import generate_ovpn_config
from config import Config

logger = logging.getLogger(__name__)


@celery.task(bind=True, name='generate_certificate')
def generate_certificate(self, provision_identity):
    """Generate OpenVPN certificate and configuration asynchronously."""
    try:
        # Update task state
        self.update_state(state='PROGRESS',
                          meta={'status': 'Generating certificate...'})

        # Create OpenVPN client cert and config
        client_conf_path = f"{Config.VPN_CLIENT_DIR}/{provision_identity}.ovpn"

        if os.path.exists(client_conf_path):
            return {
                'status': 'error',
                'message': 'Client already exists',
                'provision_identity': provision_identity
            }

        # Generate client certificate
        subprocess.run(["./easyrsa", "build-client-full", provision_identity, "nopass"],
                       check=True,
                       capture_output=True,
                       text=True)

        # Generate .ovpn file
        with open(client_conf_path, "w") as f:
            f.write(generate_ovpn_config(provision_identity))

        return {
            'status': 'success',
            'message': 'Certificate generated successfully',
            'provision_identity': provision_identity,
            'config_path': client_conf_path
        }

    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to generate certificate: {str(e)}")
        return {
            'status': 'error',
            'message': f'Failed to generate certificate: {e.stderr}',
            'provision_identity': provision_identity
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'status': 'error',
            'message': f'Unexpected error: {str(e)}',
            'provision_identity': provision_identity
        }