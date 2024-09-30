from fastapi import APIRouter

health_router = APIRouter()


@health_router.get(path="/health")
async def get_health():
    return True
