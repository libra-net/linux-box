.SILENT:
.PHONY: configs all

CURRENT_BRANCH_NAME := $(shell git branch | grep \* | cut -d ' ' -f2)
# Supported configurations (all Ubuntu LTS + latest)
CONFIGS := $(shell cat docker/configs.txt)
.PHONY: $(CONFIGS)
DOCKERFILE = docker/$@.Dockerfile
IMAGE_NAME = $(word 1,$(subst _, ,$@))
IMAGE_TAG = $(word 2,$(subst _, ,$@))
BRANCH_NAME = $@_review

all: configs

configs: $(CONFIGS)

$(CONFIGS): docker/template.Dockerfile
	git checkout $(CURRENT_BRANCH_NAME)
	git checkout -B $(BRANCH_NAME)
	cp docker/template.Dockerfile $(DOCKERFILE)
	sed -i $(DOCKERFILE) -e "s/FROM image:tag/FROM $(IMAGE_NAME):$(IMAGE_TAG)/"
	git add $(DOCKERFILE)
	git commit -m "Update Dockerfile for $@"
	git push origin $(BRANCH_NAME) --force
