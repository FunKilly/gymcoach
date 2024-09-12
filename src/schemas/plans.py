from pydantic import BaseModel


class ExerciseBase(BaseModel):
    id: int
    name: str
    description: str
    inventor_name: str | None = None


class ExercisePost(BaseModel):
    name: str
    description: str
    inventor_name: str | None = None


class ExerciseGet(ExercisePost):
    pass


class PlanBase(BaseModel):
    id: int
    name: str
    description: str
    exercises: list[ExerciseGet]


class PlanGet(PlanBase):
    pass


class PlanList(BaseModel):
    plans: list[PlanBase] | None = None


class PlanPost(BaseModel):
    name: str
    description: str
    exercises: list[int]
