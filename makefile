.PHONY: help build
.DEFAULT_GOAL := help


# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------
# adjust the shopware version here!
SW_IMAGE:=shopware
SW_VERSION:=6.6.9.0

ESSENTIALS_IMAGE:=shopware-essentials
ESSENTIALS_VERSION:=1.0.0
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

essentials: ##2 Builds, Tests and Analyzes the essentials image with the version from the Makefile
	@cd ./src && DOCKER_BUILDKIT=1 docker build --squash --build-arg VERSION=none -t dockware/$(ESSENTIALS_IMAGE):$(ESSENTIALS_VERSION) .
	make svrunit image=$(ESSENTIALS_IMAGE) tag=$(ESSENTIALS_VERSION)
	make analyze image=$(ESSENTIALS_IMAGE) tag=$(ESSENTIALS_VERSION)

shopware: ##2 Builds, Tests and Analyzes the Shopware image with the version from the Makefile
	@cd ./src && DOCKER_BUILDKIT=1 docker build --squash --build-arg VERSION=$(SW_VERSION) -t dockware/$(SW_IMAGE):$(SW_VERSION) .
	make svrunit image=$(SW_IMAGE) tag=$(SW_VERSION)
	make cypress shopware=$(SW_VERSION)
	make analyze image=$(SW_IMAGE) tag=$(SW_VERSION)

# ----------------------------------------------------------------------------------------------------------------

analyze: ##2 Shows the size of the image
	docker history --format "{{.CreatedBy}}\t\t{{.Size}}" dockware/$(image):$(tag) | grep -v "0B"
	# --------------------------------------------------
	docker save -o dev.tar dockware/$(image):$(tag)
	gzip dev.tar
	ls -lh dev.tar.gz
	# --------------------------------------------------
	rm -rf dev.tar
	rm -rf dev.tar.gz | true

# ----------------------------------------------------------------------------------------------------------------

svrunit: ##3 Runs all SVRUnit tests (make svrunit image=shopware tag=x.x.x.x)
	php ./vendor/bin/svrunit test --configuration=./tests/svrunit/suites/$(image).xml --docker-tag=$(tag) --debug --report-junit --report-html

cypress: ##3 Runs all Cypress tests
	cd ./tests/cypress && make install
	cd ./tests/cypress && make start-env version=$(shopware)
	sleep 10
	cd ./tests/cypress && make run url=http://localhost shopware=$(shopware) || (make stop-env && false)
