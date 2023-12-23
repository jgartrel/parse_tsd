#
# Setup all targets to repeatedly run as tasks
#
.PHONEY: all install install-local test run clean distclean
all: help

install: ## Install bundler dependencies
	bundle install --path vendor/bundle --binstubs --clean
	bundle package

install-local: ## Install bundler dependencies from local cache
	bundle install --path vendor/bundle --binstubs --clean --local

run:    ## Run a development server
	bundle exec ./parse_tsd.rb

testargs ?= --order random
ifneq ($(strip $(seed)),)
  testargs += --seed $(seed)
endif

test:   ## Run all tests
	bundle exec rspec $(testargs) ./spec

clean:  ## Remove all generated files
	rm -rf vendor/bundle bin tmp

distclean:  ## Remove all non-versioned files
	git clean -f -x -d

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
