from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.schemas.plans import ExercisePost, PlanBase, PlanList, PlanPost
from src.services.plans.exercises import create_exercise
from src.services.plans.plans import create_plan, fetch_plans
from src.utils.dependencies import get_db_session

plans_router = APIRouter(prefix="/plans")


@plans_router.get("", response_model=PlanList)
async def get_plans(session: AsyncSession = Depends(get_db_session)):
    result = await fetch_plans(session)

    return {"plans": result}


@plans_router.post("", response_model=PlanBase)
async def post_plan(data: PlanPost, session: AsyncSession = Depends(get_db_session)):
    return await create_plan(data, session)


@plans_router.post("/exercises")
async def post_exercise(
    data: ExercisePost, session: AsyncSession = Depends(get_db_session)
):
    return await create_exercise(data, session)
