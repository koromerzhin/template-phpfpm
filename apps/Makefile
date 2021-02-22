.DEFAULT_GOAL   := help

SUPPORTED_COMMANDS   := composer
SUPPORTS_MAKE_ARGS   := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMMAND_ARGS):;@:)
endif

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

composer.lock: composer.json
	composer update

vendor: composer.json
	composer install --no-progress --no-suggest --prefer-dist --optimize-autoloader

composer: ## Scripts for composer
ifeq ($(COMMAND_ARGS),suggests)
	@composer suggests --by-suggestion
else ifeq ($(COMMAND_ARGS),outdated)
	@composer outdated
else ifeq ($(COMMAND_ARGS),fund)
	@composer fund
else ifeq ($(COMMAND_ARGS),prod)
	@composer install --no-dev --no-progress --prefer-dist --optimize-autoloader
else ifeq ($(COMMAND_ARGS),dev)
	@composer install --no-progress --prefer-dist --optimize-autoloader
else ifeq ($(COMMAND_ARGS),update)
	@composer update
else ifeq ($(COMMAND_ARGS),validate)
	@composer validate
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make composer ARGUMENT"
	@echo "---"
	@echo "suggests: suggestions package pour PHP"
	@echo "outdated: Packet php outdated"
	@echo "fund: Discover how to help fund the maintenance of your dependencies."
	@echo "prod: Installation version de prod"
	@echo "dev: Installation version de dev"
	@echo "update: COMPOSER update"
	@echo "validate: COMPOSER validate"
endif