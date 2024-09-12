from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from src.config import settings


def singleton_function(func):
    instance = None

    def wrapper(*args, **kwargs):
        nonlocal instance
        if instance is None:
            instance = func(*args, **kwargs)
        return instance

    return wrapper


@singleton_function
def get_async_engine(database_url):
    return create_async_engine(database_url)


def get_async_session_factory():
    engine = get_async_engine(database_url=str(settings.SQLALCHEMY_DATABASE_URI))
    # Create an asynchronous session factory
    return async_sessionmaker(
        engine, expire_on_commit=False, autoflush=False, autocommit=False
    )


class Base(DeclarativeBase):
    pass
