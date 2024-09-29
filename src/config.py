from typing import Literal

from pydantic import PostgresDsn, computed_field
from pydantic_core import MultiHostUrl
from urllib.parse import quote_plus
from pydantic_settings import BaseSettings, SettingsConfigDict

import logging
log = logging.getLogger(__name__)



class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_ignore_empty=True, extra="ignore"
    )

    ENVIRONMENT: Literal["local", "staging", "production"] = "local"

    POSTGRES_SERVER: str
    POSTGRES_PORT: int = 5432
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str = ""
    POSTGRES_DB: str = ""

    @computed_field  # type: ignore[prop-decorator]
    @property
    def SQLALCHEMY_DATABASE_URI(self) -> PostgresDsn:
        encoded_password = quote_plus(self.POSTGRES_PASSWORD)
        log.error(f"port:{self.POSTGRES_PORT} server:{self.POSTGRES_SERVER} user:{self.POSTGRES_USER} password:{self.POSTGRES_PASSWORD} db:{self.POSTGRES_DB}")
        return MultiHostUrl.build(
            scheme="postgresql+asyncpg",
            username=self.POSTGRES_USER,
            password=encoded_password,
            host=self.POSTGRES_SERVER,
            port=int(self.POSTGRES_PORT),
            path=self.POSTGRES_DB,
        )


def get_config():
    return Settings()
