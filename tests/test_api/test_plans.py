import pytest

from src.models.plans import Exercise, Plan
from src.schemas.plans import PlanPost


@pytest.fixture
async def exercises(db_session):
    ex1 = Exercise(name="plank", description="ex description")
    ex2 = Exercise(name="squat", description="ex description")

    db_session.add(ex1)
    db_session.add(ex2)
    await db_session.commit()

    return [ex1.id, ex2.id]


@pytest.fixture
async def plans(db_session, exercises):
    ex1 = Exercise(name="deadlift", description="ex description")
    ex2 = Exercise(name="squat", description="ex description")

    plan1 = Plan(
        name="Test plan", description="plan for unit tests", exercises=[ex1, ex2]
    )
    db_session.add(plan1)
    await db_session.commit()


async def test_create_plan(client, exercises, db_session):
    body = PlanPost(
        name="Kozak plan 1", description="Plan to gain muscles", exercises=exercises
    )

    response = client.post("/plans", json=body.model_dump())

    assert response.status_code == 200


async def test_get_plans(client, db_session, plans):
    response = client.get("/plans")

    assert response.status_code == 200
