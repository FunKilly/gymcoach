from sqlalchemy.ext.asyncio import AsyncSession

from .db import get_async_session_factory


# Dependency to get the async session for each request
async def get_db_session() -> AsyncSession:
    async_session_factory = get_async_session_factory()
    async with async_session_factory() as session:
        yield session
