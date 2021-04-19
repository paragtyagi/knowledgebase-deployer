import requests
from django.utils.functional import lazy


def get_ec2_info(value):
    res = requests.get(f"http://169.254.169.254/latest/meta-data/{value}")
    return res.text


DEBUG = False

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '*84e*(n8613y#_hl^i(i6h!t47m#6!b_@fc=hpi9kszlha=qv-'

ALLOWED_HOSTS = [
    lazy(get_ec2_info, str)("public-hostname"),
    lazy(get_ec2_info, str)("public-ipv4"),
]
