#Dockerfile vars

#vars
IMAGENAME=docker-matrix
IMAGEFULLNAME=avhost/${IMAGENAME}
BRANCH=${shell git symbolic-ref --short HEAD}
LASTCOMMIT=$(shell git log -1 --pretty=short | tail -n 1 | tr -d " " | tr -d "UPDATE:")
TAG_SYN=v1.81.0
BV_SYN=release-v1.81

help:
	    @echo "Makefile arguments:"
	    @echo ""
	    @echo "Makefile commands:"
	    @echo "build"
			@echo "publish-latest"
			@echo "publish-tag"

.DEFAULT_GOAL := all

ifeq (${BRANCH}, master) 
	BRANCH=latest
endif

ifneq ($(shell echo $(LASTCOMMIT) | grep -E '^v([0-9]+\.){0,2}(\*|[0-9]+)'),)
	BRANCH=${LASTCOMMIT}
else
	BRANCH=latest
endif


build:
	@echo ">>>> Build docker image"
	docker build --build-arg TAG_SYN=${TAG_SYN} --build-arg BV_SYN=${BV_SYN} -t ${IMAGEFULLNAME}:${BRANCH} .

push:
	@echo ">>>> Publish docker image"
	@docker buildx rm buildkit
	@docker buildx create --use --name buildkit
	docker buildx build --build-arg TAG_SYN=${TAG_SYN} --build-arg BV_SYN=${BV_SYN} --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:${BRANCH} .
	docker buildx build --build-arg TAG_SYN=${TAG_SYN} --build-arg BV_SYN=${BV_SYN} --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:latest .
	@docker buildx rm buildkit

all: build push
