.PHONY: help build
.DEFAULT_GOAL := help


help:
	@echo "PROJECT COMMANDS"
	@echo "--------------------------------------------------------------------------------------------"
	@printf "\033[33mInstallation:%-30s\033[0m %s\n"
	@grep -E '^[a-zA-Z_-]+:.*?##1 .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?##1 "}; {printf "\033[33m  - %-30s\033[0m %s\n", $$1, $$2}'
	@echo "--------------------------------------------------------------------------------------------"
	@printf "\033[36mDevelopment:%-30s\033[0m %s\n"
	@grep -E '^[a-zA-Z_-]+:.*?##2 .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?##2 "}; {printf "\033[36m  - %-30s\033[0m %s\n", $$1, $$2}'
	@echo "--------------------------------------------------------------------------------------------"
	@printf "\033[32mTests:%-30s\033[0m %s\n"
	@grep -E '^[a-zA-Z_-]+:.*?##3 .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?##3 "}; {printf "\033[32m  - %-30s\033[0m %s\n", $$1, $$2}'

# ----------------------------------------------------------------------------------------------------------------

install: ##1 Installs all dependencies
	composer install

clean: ##1 Clears all dependencies dangling images
	rm -rf vendor/*
	rm -rf node_modules/*
	docker images -aq -f 'dangling=true' | xargs docker rmi
	docker volume ls -q -f 'dangling=true' | xargs docker volume rm

# ----------------------------------------------------------------------------------------------------------------

all: ##2 Builds, Tests and Analyzes the image (make all version=xyz shopware=xyz)
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
ifndef shopware
	$(error Please provide the argument shopware=xyz to run the command)
endif
	make build   version=$(version) shopware=$(shopware)
	make svrunit version=$(version)
	make cypress version=$(version) shopware=$(shopware)
	make analyze version=$(version)

build: ##2 Builds the image (make build version=xyz shopware=xyz)
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
ifndef shopware
	$(error Please provide the argument shopware=xyz for the Shopware version to run the command)
endif
	php ./scripts/create-variables.php $(shopware)
	@cd ./src && DOCKER_BUILDKIT=1 docker build --no-cache --squash --build-arg VERSION=$(version) -t dockware/dev:$(version) .

analyze: ##2 Shows the size of the image (make analyze version=xyz)
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
	docker history --format "{{.CreatedBy}}\t\t{{.Size}}" dockware/dev:$(version) | grep -v "0B"
	# --------------------------------------------------
	docker save -o dev.tar dockware/dev:$(version)
	gzip dev.tar
	ls -lh dev.tar.gz
	# --------------------------------------------------
	rm -rf dev.tar
	rm -rf dev.tar.gz | true

# ----------------------------------------------------------------------------------------------------------------

svrunit: ##3 Runs all SVRUnit tests (make svrunit version=xyz)
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
	php ./vendor/bin/svrunit test --configuration=./tests/svrunit/dev.xml --docker-tag=$(version) --debug --report-junit --report-html

cypress: ##3 Runs all Cypress tests (make cypress version=xyz shopware=xyz)
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
ifndef shopware
	$(error Please provide the argument shopware=xyz to run the command)
endif
	cd ./tests/cypress && make install
	cd ./tests/cypress && make start-env version=$(version)
	sleep 10
	cd ./tests/cypress && make run url=http://localhost shopware=$(shopware) || (make stop-env && false)
