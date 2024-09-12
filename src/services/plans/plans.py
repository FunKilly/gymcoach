from sqlalchemy.ext.asyncio import AsyncSession

from src.models.plans import Exercise, Plan
from src.schemas.plans import PlanPost


async def fetch_plans(session: AsyncSession):
    plans = await Plan.get_all_plans(session)
    return plans


async def create_plan(data: PlanPost, session: AsyncSession):
    exercises = [
        await Exercise.get_exercise_by_id(session, exercise_id)
        for exercise_id in data.exercises
    ]

    plan = Plan(name=data.name, description=data.description, exercises=exercises)

    await plan.create(session)

    return plan
