.DEFAULT_GOAL := help
STACK         := phpfpm
NETWORK       := proxynetwork
WWW           := $(STACK)_phpfpm
WWWFULLNAME   := $(WWW).1.$$(docker service ps -f 'name=$(PRWWWOXY)' $(WWW) -q --no-trunc | head -n1)

%:
	@:

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

composer-suggests: ## suggestions package pour PHP
	docker exec $(WWWFULLNAME) make composer-suggests

composer-outdated: ## Packet php outdated
	docker exec $(WWWFULLNAME) make composer-outdated

composer-prod: ## Installation version de production
	docker exec $(WWWFULLNAME) make composer-prod

composer-dev: ## Installation version de dev
	docker exec $(WWWFULLNAME) make composer-dev

composer-dev-ci: ## Installation version de dev
	cd apps && make composer-dev

composer-update: ## COMPOSER update
	docker exec $(WWWFULLNAME) make composer-update

composer-validate: ## COMPOSER validate
	docker exec $(WWWFULLNAME) make composer-validate

composer-validate-ci: ## COMPOSER validate
	cd apps && make composer-validate

contributors: node_modules ## Contributors
	@npm run contributors

contributors-add: node_modules ## add Contributors
	@npm run contributors add

contributors-check: node_modules ## check Contributors
	@npm run contributors check

contributors-generate: node_modules ## generate Contributors
	@npm run contributors generate

docker-create-network: ## create network
	docker network create --driver=overlay $(NETWORK)

docker-deploy: ## deploy
	docker stack deploy -c docker-compose.yml $(STACK)

docker-image-pull: ## Get docker image
	docker image pull httpd
	docker image pull koromerzhin/phpfpm:latest

docker-logs: ## logs docker
	docker service logs -f --tail 100 --raw $(WWWFULLNAME)

docker-ls: ## docker service
	@docker stack services $(STACK)

docker-stop: ## docker stop
	@docker stack rm $(STACK)

git-commit: node_modules ## Commit data
	npm run commit

git-check: node_modules ## CHECK before
	@make contributors-check -i
	@git status

install: ## Installation
	@make docker-deploy -i

linter: apps/vendor node_modules ## linter
	@make linter-phpstan -i
	@make linter-phpcpd -i
	@make linter-phpcs -i
	@make linter-phpmd -i
	@make linter-readme -i

linter-readme: node_modules ## linter README.md
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

linter-phpinsights: apps/vendor ## PHP Insights
	docker exec $(WWWFULLNAME) make linter-phpinsights

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

node_modules: ## npm install
	npm install

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
