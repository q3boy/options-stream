-RELEASE_DIR := out/release/
-COVERAGE_DIR := out/test/
-RELEASE_COPY := lib
-COVERAGE_COPY := lib tests


-BIN_MOCHA := ./node_modules/.bin/mocha
-BIN_JSCOVER := ./node_modules/.bin/jscover
-BIN_COFFEE := ./node_modules/coffee-script/bin/coffee -c
-BIN_YAML := ./node_modules/.bin/yaml2json -sp

-TESTS := $(shell find tests -type f -name test-*)

-COFFEE_LIB := $(shell find lib -type f -name '*.coffee')
-COFFEE_TEST := $(shell find tests -type f -name 'test-*.coffee')

-COFFEE_RELEASE := $(addprefix $(-RELEASE_DIR),$(-COFFEE_LIB) )

-COFFEE_COVERAGE := $(-COFFEE_LIB)
-COFFEE_COVERAGE += $(-COFFEE_TEST)
-COFFEE_COVERAGE := $(addprefix $(-COVERAGE_DIR),$(-COFFEE_COVERAGE) )

-COVERAGE_FILE := coverage.html
-COVERAGE_TESTS := $(addprefix $(-COVERAGE_DIR),$(-TESTS))
-COVERAGE_TESTS := $(-COVERAGE_TESTS:.coffee=.js)

default: dev

json:
	@echo "make package.json"
	@$(-BIN_YAML) ./package.yaml


dev: clean json
	@$(-BIN_MOCHA) \
		--colors \
		--compilers coffee:coffee-script \
		--reporter spec \
		--growl \
		$(-TESTS)

test: clean json
	@$(-BIN_MOCHA) \
		--compilers coffee:coffee-script \
		--reporter spec \
		$(-TESTS)

release: dev
	@echo 'copy files'
	@mkdir -p $(-RELEASE_DIR)
	@cp -r $(-RELEASE_COPY) $(-RELEASE_DIR)

	@echo "compile coffee-script files"
	@$(-BIN_COFFEE) -b $(-COFFEE_RELEASE)
	@rm -f $(-COFFEE_RELEASE)

	@echo "all codes in \"$(-RELEASE_DIR)\""


test-cov: clean json
	@echo 'copy files'
	@mkdir -p $(-COVERAGE_DIR)
	@cp -r $(-COVERAGE_COPY) $(-COVERAGE_DIR)

	@echo "compile coffee-script files"
	@$(-BIN_COFFEE) -b $(-COFFEE_COVERAGE)
	@rm -f $(-COFFEE_COVERAGE)

	@echo "generate coverage files"
	@$(-BIN_JSCOVER) $(-COVERAGE_DIR)/lib $(-COVERAGE_DIR)/lib

	@echo "run coverage test"
	@$(-BIN_MOCHA) \
		--reporter spec \
		$(-COVERAGE_TESTS)

	@echo "make coverage report"
	@$(-BIN_MOCHA) \
		--reporter html-cov \
		$(-COVERAGE_TESTS) \
		> $(-COVERAGE_FILE)

	@echo "test report saved \"$(-COVERAGE_FILE)\""
	@if [ `echo $$OSTYPE | grep -c 'darwin'` -eq 1 ]; then open $(-COVERAGE_FILE); fi

.-PHONY: default

clean:
	@echo 'clean'
	@-rm -fr out
	@-rm -f package.json
	@-rm -f coverage.html


