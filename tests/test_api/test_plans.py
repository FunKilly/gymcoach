import pytest

from src.models.plans import Exercise
from src.schemas.plans import PlanPost


@pytest.fixture
async def exercises(db_session):
    ex1 = Exercise(name="plank", description="ex description")
    ex2 = Exercise(name="squat", description="ex description")

    db_session.add(ex1)
    db_session.add(ex2)
    await db_session.commit()

    return [ex1.id, ex2.id]


async def test_create_plan(client, exercises, db_session):
    body = PlanPost(
        name="Kozak plan", description="Plan to gain muscles", exercises=exercises
    )

    response = client.post("/plans", json=body.model_dump())

    assert response.status_code == 200
