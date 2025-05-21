
.PHONY: clean lint checktypes checkstyle fixstyle test test-all

clean:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +
	rm -fr .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache
	rm -fr .venv/

lint: checktypes checkstyle ## run all checks

liccheck:
	poetry export -f requirements.txt -o requirements.txt
	poetry run liccheck || true
	rm -f requirements.txt

checktypes: .venv ## check types with mypy
	poetry run mypy --ignore-missing-imports testrepo tests

checkstyle: .venv ## check style with flake8, black and isort
	poetry run flake8 testrepo
	poetry run isort --check-only --profile black testrepo tests
	poetry run black -l 99 --check --diff testrepo tests

fixstyle: .venv ## fix black and isort style violations
	poetry run isort --profile black testrepo tests
	poetry run black -l 99 testrepo tests

test: .venv ## quick run of unit tests
	poetry run pytest --verbose --capture=no --cov=testrepo --cov-fail-under=25
	
test-all: lint test

.venv: poetry.lock
	poetry install
	@touch -c .venv

poetry.lock:
	poetry lock -vvv
	@touch -c poetry.lock

-include Makefile_aux
-include Makefile_override
  