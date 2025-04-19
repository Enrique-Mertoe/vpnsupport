import os
from config import Config


def generate_ovpn_config(provision_identity):
    """Generate OpenVPN client configuration file content.

    Args:
        provision_identity (str): The unique identifier for the client

    Returns:
        str: The complete OpenVPN client configuration
    """
    # Base configuration template
    config = [
        "client",
        "dev tun",
        "proto udp",
        f"remote {Config.VPN_HOST} {Config.VPN_PORT}",
        "resolv-retry infinite",
        "nobind",
        "persist-key",
        "persist-tun",
        "remote-cert-tls server",
        "auth SHA512",
        "ignore-unknown-option block-outside-dns",
        "verb 3"
    ]

    # Read certificate files
    cert_path = os.path.join(Config.VPN_CLIENT_DIR, f"{provision_identity}.crt")
    key_path = os.path.join(Config.VPN_CLIENT_DIR, f"{provision_identity}.key")
    ca_path = os.path.join(Config.VPN_CLIENT_DIR, "ca.crt")
    tls_crypt_path = os.path.join(Config.VPN_CLIENT_DIR, "tls-crypt.key")

    # Add CA certificate
    config.append("<ca>")
    with open(ca_path, 'r') as f:
        config.append(f.read().strip())
    config.append("</ca>")

    # Add client certificate
    config.append("<cert>")
    with open(cert_path, 'r') as f:
        config.append(f.read().strip())
    config.append("</cert>")

    # Add client key
    config.append("<key>")
    with open(key_path, 'r') as f:
        config.append(f.read().strip())
    config.append("</key>")

    # Add TLS crypt key if exists
    if os.path.exists(tls_crypt_path):
        config.append("<tls-crypt>")
        with open(tls_crypt_path, 'r') as f:
            config.append(f.read().strip())
        config.append("</tls-crypt>")

    return "\n".join(config)
