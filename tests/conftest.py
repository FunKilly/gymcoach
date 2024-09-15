import os

import pytest

ENVIRONMENT_VARIABLES = {
    "POSTGRES_SERVER": "localhost",
    "POSTGRES_USER": "postgres",
    "POSTGRES_PASSWORD": "postgres",
    "POSTGRES_DB": "gymcoach-db",
}


@pytest.fixture(scope="session", autouse=True)
def set_env():
    for k, v in ENVIRONMENT_VARIABLES.items():
        os.environ[k] = v
