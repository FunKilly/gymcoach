from fastapi import APIRouter


plans_router = APIRouter()


@plans_router.get(path="/health")
async def get_health():
    return True