import re
import hashlib
from functools import wraps
from flask import request, jsonify
from config import Config


def validate_provision_identity(provision_identity):
    """Validate the format of a provision identity."""
    if not re.match(Config.ALLOWED_PROVISION_IDENTITY_PATTERN, provision_identity):
        raise ValueError("Invalid provision identity format")
    return True


def generate_secret(provision_identity):
    """Generate a secret for a provision identity."""
    # In production, use a more secure method to generate secrets
    return hashlib.sha256(f"{provision_identity}{Config.SECRET_KEY}".encode()).hexdigest()


def verify_secret(provision_identity, secret):
    """Verify if the provided secret is valid for the provision identity."""
    expected_secret = generate_secret(provision_identity)
    return secret == expected_secret


def require_secret(f):
    """Decorator to require secret authentication."""

    @wraps(f)
    def decorated_function(*args, **kwargs):
        provision_identity = kwargs.get('provision_identity')
        secret = kwargs.get('secret')

        if not provision_identity or not secret:
            return jsonify({"error": "Missing required parameters"}), 400

        if not verify_secret(provision_identity, secret):
            return jsonify({"error": "Unauthorized"}), 401

        return f(*args, **kwargs)

    return decorated_function
