CONTAINER ?= "gymcoach-api"

# run
run:
	docker-compose up --build

# build
build:
	docker-compose build

# lint
lint:
	black --line-length=90 . && isort . && flake8 --max-line-length=120

# Enter the container
bash:
	docker exec -it ${CONTAINER} bash

# Enter to db
shell:
	docker exec -it api-db bash -c "psql -U oskar -d rating_portal"

# Apply migrations
migrate:
	docker exec -it ${CONTAINER} bash -c "cd portal && alembic upgrade head"