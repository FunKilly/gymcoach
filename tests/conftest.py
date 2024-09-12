from collections.abc import AsyncGenerator, Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import (AsyncConnection, AsyncEngine, AsyncSession,
                                    async_sessionmaker)

from src.app import app
from src.utils.db import get_async_engine


@pytest.fixture(scope="session")
async def client() -> Generator[TestClient, None, None]:
    with TestClient(app) as c:
        yield c


@pytest.fixture(scope="session", params=[{"echo": False}], ids=["echo=False"])
async def db_engine(
    request: pytest.FixtureRequest,
) -> AsyncGenerator[AsyncEngine, None, None]:
    """Create the database engine."""
    engine = get_async_engine("sqlite+aiosqlite:///")

    try:
        yield engine
    finally:
        # for AsyncEngine created in function scope, close and
        # clean-up pooled connections
        await engine.dispose()


@pytest.fixture(scope="session")
async def _database_objects(
    db_engine: AsyncEngine,
) -> AsyncGenerator[None, None]:
    """Create the database objects (tables, etc.)."""
    from src.utils.db import Base

    # Enters a transaction
    # https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html#sqlalchemy.ext.asyncio.AsyncConnection.begin
    try:
        async with db_engine.begin() as conn:
            await conn.run_sync(Base.metadata.drop_all)
            await conn.run_sync(Base.metadata.create_all)
        yield
    finally:

        # Clean up after the testing session is over
        async with db_engine.begin() as conn:
            await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture(scope="session")
async def db_connection(
    db_engine: AsyncEngine,
) -> AsyncGenerator[AsyncConnection, None]:
    """Create a database connection."""
    async with db_engine.connect() as conn:
        yield conn


@pytest.fixture()
async def db_session(
    db_engine: AsyncEngine,
    _database_objects: None,
) -> AsyncGenerator[AsyncSession, None]:
    """Create a database session."""
    async_session_factory = async_sessionmaker(
        db_engine, expire_on_commit=False, autoflush=False, autocommit=False
    )
    async with async_session_factory() as session:
        yield session
