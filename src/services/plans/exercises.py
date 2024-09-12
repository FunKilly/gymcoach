from sqlalchemy.ext.asyncio import AsyncSession

from src.models.plans import Exercise
from src.schemas.plans import ExercisePost


async def create_exercise(data: ExercisePost, session: AsyncSession):
    exercise = Exercise(
        name=data.name, description=data.description, inventor_name=data.inventor_name
    )

    exercise = await exercise.create(session)
    return exercise


async def get_exercises(session: AsyncSession):
    return await Exercise.get_all_exercises(session)


async def get_exercise(session: AsyncSession, exercise_id: int):
    return await Exercise.get_exercise_by_id(session, exercise_id)
