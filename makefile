.PHONY: help build
.DEFAULT_GOAL := help


# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------
# adjust the shopware version here!
SW_VERSION:=6.6.9.0
# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------


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
	cd tests/cypress && make clean
	cd tests/cypress && make install

clean: ##1 Clears all dependencies dangling images
	rm -rf vendor/*
	rm -rf node_modules/*
	docker images -aq -f 'dangling=true' | xargs docker rmi
	docker volume ls -q -f 'dangling=true' | xargs docker volume rm

# ----------------------------------------------------------------------------------------------------------------

all: ##2 Builds, Tests and Analyzes the image
	make build
	make svrunit
	make cypress
	make analyze

build: ##2 Builds the image
	@cd ./src && DOCKER_BUILDKIT=1 docker build --squash --build-arg VERSION=$(SW_VERSION) -t dockware/dev:$(SW_VERSION) .

analyze: ##2 Shows the size of the image
	docker history --format "{{.CreatedBy}}\t\t{{.Size}}" dockware/dev:$(SW_VERSION) | grep -v "0B"
	# --------------------------------------------------
	docker save -o dev.tar dockware/dev:$(SW_VERSION)
	gzip dev.tar
	ls -lh dev.tar.gz
	# --------------------------------------------------
	rm -rf dev.tar
	rm -rf dev.tar.gz | true

# ----------------------------------------------------------------------------------------------------------------

svrunit: ##3 Runs all SVRUnit tests
	php ./vendor/bin/svrunit test --configuration=./tests/svrunit/shopware/shopware.xml --docker-tag=$(SW_VERSION) --debug --report-junit --report-html

cypress: ##3 Runs all Cypress tests
	cd ./tests/cypress && make install
	cd ./tests/cypress && make start-env version=$(SW_VERSION)
	sleep 10
	cd ./tests/cypress && make run url=http://localhost shopware=$(SW_VERSION) || (make stop-env && false)
