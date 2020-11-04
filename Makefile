.DEFAULT_GOAL := help
STACK         := phpfpm
NETWORK       := proxynetwork
WWW           := $(STACK)_phpfpm
WWWFULLNAME   := $(WWW).1.$$(docker service ps -f 'name=$(PRWWWOXY)' $(WWW) -q --no-trunc | head -n1)

%:
	@:

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

package-lock.json: package.json
	npm install

node_modules: package-lock.json
	npm install

apps/composer.lock: apps/composer.json
	docker exec $(PHPFPMFULLNAME) make composer.lock
	
apps/vendor: apps/composer.lock
	docker exec $(PHPFPMFULLNAME) make vendor

composer-suggests: ## suggestions package pour PHP
	docker exec $(WWWFULLNAME) make composer-suggests

composer-outdated: ## Packet php outdated
	docker exec $(WWWFULLNAME) make composer-outdated

composer-dev-ci: ## Installation version de dev
	cd apps && make composer-dev

composer-update: ## COMPOSER update
	docker exec $(WWWFULLNAME) make composer-update

composer-validate: ## COMPOSER validate
	docker exec $(WWWFULLNAME) make composer-validate

composer-validate-ci: ## COMPOSER validate
	cd apps && make composer-validate

contributors: ## Contributors
	@npm run contributors

contributors-add: ## add Contributors
	@npm run contributors add

contributors-check: ## check Contributors
	@npm run contributors check

contributors-generate: ## generate Contributors
	@npm run contributors generate

docker-create-network: ## create network
	docker network create --driver=overlay $(NETWORK)

docker-deploy: ## deploy
	docker stack deploy -c docker-compose.yml $(STACK)

docker-image-pull: ## Get docker image
	docker image pull httpd
	docker image pull koromerzhin/phpfpm:7.4.12-xdebug

docker-logs: ## logs docker
	docker service logs -f --tail 100 --raw $(WWWFULLNAME)

docker-ls: ## docker service
	@docker stack services $(STACK)

docker-stop: ## docker stop
	@docker stack rm $(STACK)

git-commit: ## Commit data
	npm run commit

git-check: ## CHECK before
	@make contributors-check -i
	@git status

install: node_modules ## Installation
	@make docker-deploy -i

linter: apps/vendor node_modules ## linter
	@make linter-phpstan -i
	@make linter-phpcpd -i
	@make linter-phpcs -i
	@make linter-phpmd -i
	@make linter-readme -i

linter-readme: ## linter README.md
	@npm run linter-markdown README.md

linter-phpcbf: apps/vendor ## fixe le code PHP à partir d'un standard
	docker exec $(WWWFULLNAME) make linter-phpcbf

linter-phpcpd: phpcpd.phar ## Vérifie s'il y a du code dupliqué
	docker exec $(WWWFULLNAME) make linter-phpcpd

linter-phpcs: apps/vendor ## indique les erreurs de code non corrigé par PHPCBF
	docker exec $(WWWFULLNAME) make linter-phpcs

linter-phpcs-onlywarning: apps/vendor ## indique les erreurs de code non corrigé par PHPCBF
	docker exec $(WWWFULLNAME) make linter-phpcs-onlywarning

linter-phpcs-onlyerror: apps/vendor ## indique les erreurs de code non corrigé par PHPCBF
	docker exec $(WWWFULLNAME) make linter-phpcs-onlyerror

linter-phpcs-onlyerror-ci: apps/vendor ## indique les erreurs de code non corrigé par PHPCBF
	cd apps && make linter-phpcs-onlyerror

linter-phpmd: apps/vendor ## indique quand le code PHP contient des erreurs de syntaxes ou des erreurs
	docker exec $(WWWFULLNAME) make linter-phpmd

linter-phpmd-ci: apps/vendor ## indique quand le code PHP contient des erreurs de syntaxes ou des erreurs
	cd apps && make linter-phpmd

linter-phpmnd: apps/vendor ## Si des chiffres sont utilisé dans le code PHP, il est conseillé d'utiliser des constantes
	docker exec $(WWWFULLNAME) make linter-phpmnd

linter-phpmnd-ci: apps/vendor ## Si des chiffres sont utilisé dans le code PHP, il est conseillé d'utiliser des constantes
	cd apps && make linter-phpmnd

linter-phpstan: apps/vendor ## regarde si le code PHP ne peux pas être optimisé
	docker exec $(WWWFULLNAME) make linter-phpstan

linter-phpstan-ci: apps/vendor ## regarde si le code PHP ne peux pas être optimisé
	cd apps && make linter-phpstan

ssh: ## ssh
	docker exec -ti $(WWWFULLNAME) /bin/bash

tests-behat: apps/vendor ## Lance les tests behat
	docker exec $(WWWFULLNAME) make tests-behat

tests-behat-ci: apps/vendor ## Lance les tests behat
	cd apps && make tests-behat

tests-launch: apps/vendor ## Launch all tests
	@make tests-behat -i
	@make tests-phpunit-unit-integration -i

tests-phpunit-unit-integration: apps/vendor ## lance les tests phpunit
	docker exec $(WWWFULLNAME) make tests-phpunit-unit-integration

tests-phpunit-unit-integration-ci: apps/vendor ## lance les tests phpunit
	cd apps && make tests-phpunit-unit-integration

tests-phpunit: apps/vendor ## lance les tests phpunit
	docker exec $(WWWFULLNAME) make tests-phpunit
