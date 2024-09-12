from datetime import datetime

from sqlalchemy import (Column, DateTime, ForeignKey, Integer, String, Table,
                        select)
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import relationship, selectinload

from src.utils.db import Base

plan_exercise_association = Table(
    "plan_exercise_association",
    Base.metadata,
    Column(
        "plan_id", Integer, ForeignKey("plan.id", ondelete="CASCADE"), primary_key=True
    ),
    Column(
        "exercise_id",
        Integer,
        ForeignKey("exercise.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)


class Plan(Base):
    __tablename__ = "plan"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)

    created_at = Column(DateTime, default=datetime.now())

    exercises = relationship(
        "Exercise", secondary=plan_exercise_association, back_populates="plans"
    )

    @classmethod
    async def get_all_plans(cls, session: AsyncSession) -> list["Plan"]:
        query = select(Plan).options(selectinload(Plan.exercises))
        result = await session.execute(query)
        return result.scalars().all()

    @classmethod
    async def get_plan_by_id(cls, session: AsyncSession, plan_id) -> "Plan":
        query = select(Plan).filter(Plan.id == plan_id)
        result = await session.execute(query)
        return result.scalars().one_or_none()

    async def create(self, session: AsyncSession) -> "Plan":
        session.add(self)
        await session.commit()
        return self


class Exercise(Base):
    __tablename__ = "exercise"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)
    inventor_name = Column(String)

    created_at = Column(DateTime, default=datetime.now())

    plans = relationship(
        "Plan", secondary=plan_exercise_association, back_populates="exercises"
    )

    @classmethod
    async def get_all_exercises(cls, session: AsyncSession) -> list["Exercise"]:
        query = select(Exercise)
        result = await session.execute(query)
        return result.scalars().all()

    @classmethod
    async def get_exercise_by_id(cls, session: AsyncSession, exercise_id) -> "Exercise":
        query = select(Exercise).filter(Exercise.id == exercise_id)
        result = await session.execute(query)
        return result.scalars().one_or_none()

    async def create(self, session: AsyncSession) -> "Exercise":
        session.add(self)
        await session.commit()
        return self
