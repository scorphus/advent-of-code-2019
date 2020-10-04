deps:
	@mix deps.get

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

.PHONY: deps format check-format credo dialyzer lint test coverage coverage-ci
