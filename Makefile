.PHONY: all docs install format github lint release test test-ci


PACKAGE := $(shell grep '^PACKAGE =' setup.py | cut -d '"' -f2)
VERSION := $(shell head -n 1 $(PACKAGE)/assets/VERSION)
LEAD := $(shell head -n 1 LEAD.md)


all:
	@grep '^\.PHONY' Makefile | cut -d' ' -f2- | tr ' ' '\n'

docs:
	python docs/build.py

format:
	black $(PACKAGE) tests

install:
	pip install --upgrade -e .[bigquery,ckan,excel,gsheets,html,json,ods,pandas,s3,server,spss,sql,dev]

lint:
	black $(PACKAGE) tests --check
	pylama $(PACKAGE) tests
	# mypy $(PACKAGE) --ignore-missing-imports

release:
	git checkout main && git pull origin && git fetch -p
	# TODO: recover (failing ATM)
	# @make docs && echo '\nWe are including a docs update to the commit\n'
	@git log --pretty=format:"%C(yellow)%h%Creset %s%Cgreen%d" --reverse -20
	@echo "\nReleasing v$(VERSION) in 10 seconds. Press <CTRL+C> to abort\n" && sleep 10
	make test && git commit -a -m 'v$(VERSION)' && git tag -a v$(VERSION) -m 'v$(VERSION)'
	git push --follow-tags

test:
	make lint
	pytest --cov ${PACKAGE} --cov-report term-missing --cov-fail-under 70 --timeout=300

test-ci:
	make lint
	pytest --cov ${PACKAGE} --cov-report term-missing --cov-fail-under 80 --timeout=300 --ci
