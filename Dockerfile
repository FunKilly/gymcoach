FROM python:3.12-slim-bullseye AS base

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends  \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /home/gymcoach

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=off \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_VERSION=1.8.3 \
    VIRTUAL_ENV="/home/src/.venv"

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python - \
    && export PATH="/root/.local/bin:$PATH"

# Ensure Poetry is available in PATH
ENV PATH="/root/.local/bin:$PATH"

# Copy project files for dependency installation
COPY pyproject.toml poetry.lock ./

# Install Python dependencies without creating a virtual environment
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi \
    && pip install --upgrade pip==21.1.1

# Copy application and tests
COPY tests/ tests/
COPY src/ src/
COPY alembic.ini .

EXPOSE 8000

RUN ls
RUN echo "Running the migrations and starting the app"

# Run Alembic migrations and start FastAPI application
CMD ["bash", "-c", "alembic upgrade head && uvicorn src.app:app --host 0.0.0.0 --port 8000 --reload"]

