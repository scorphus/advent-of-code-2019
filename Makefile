deps:
	@mix deps.get

setup: deps
	@type -p pre-commit >/dev/null 2>&1 || \
		(echo "Please install pre-commit and try again"; exit 1)
	@pre-commit install -f --hook-type pre-commit
	@pre-commit install -f --hook-type pre-push

format:
	@mix format

check-format:
	@mix format --check-equivalent --check-formatted

credo:
	@mix credo --strict

dialyzer:
	@mix dialyzer

lint: check-format credo dialyzer

test:
	@mix compile --all-warnings --warnings-as-errors
	@mix test --trace --cover

coverage:
	@mix coveralls.html
	@echo "file://$$(pwd)/cover/excoveralls.html"

coverage-ci: SHELL := /bin/bash
coverage-ci:
	@mix coveralls.json
	@bash <(curl -s https://codecov.io/bash)

.PHONY: deps setup format check-format credo dialyzer lint test coverage coverage-ci
