"""Development settings."""
from .base import *  # noqa

DEBUG = True

# By default allow local hosts in dev
if not ALLOWED_HOSTS:
    ALLOWED_HOSTS = ["127.0.0.1", "localhost"]