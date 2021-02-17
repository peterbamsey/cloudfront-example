SHELL := /bin/bash

FUNCTION_NAME=cloudfront-example
BUILD_FOLDER=build/$(FUNCTION_NAME)
SOURCE_FOLDER=source/$(FUNCTION_NAME)

export PYLINTHOME=.

init:
	rm -rf cloudfront-example-env; \
	virtualenv cloudfront-example-env -p python3; \
	source cloudfront-example-env/bin/activate; \
	pip install pylint

lint:
	source cloudfront-example-env/bin/activate; \
	pylint $(SOURCE_FOLDER)/*.py

build: init lint clean
	mkdir -p $(BUILD_FOLDER)
	source cloudfront-example-env/bin/activate; \
	pip install -r $(SOURCE_FOLDER)/requirements.txt; \
	cp $(SOURCE_FOLDER)/*.py $(BUILD_FOLDER)/

clean:
	rm -rf $(BUILD_FOLDER)