.SILENT:
.PHONY: tests help push

CURRENT_BRANCH_NAME := $(shell git branch | grep \* | cut -d ' ' -f2)
# Supported configurations (all Ubuntu LTS + latest)
CONFIGS := $(shell cat docker/configs.txt)
TEST_CONFIGS := $(foreach CONFIG,$(CONFIGS),$(CONFIG)_test)
.PHONY: $(CONFIGS) $(TEST_CONFIGS)
DOCKERFILE = docker/Dockerfile
IMAGE_NAME = $(word 1,$(subst _, ,$(subst -, ,$@)))
IMAGE_TAG = $(word 2,$(subst _, ,$(subst -, ,$@)))
PUSH_BRANCH_NAME = $@

help:
	echo "Please pick a target: 'tests' or 'push'"

tests: $(TEST_CONFIGS)

$(TEST_CONFIGS): docker/template.Dockerfile
	git checkout $(CURRENT_BRANCH_NAME)
	git checkout -B $(PUSH_BRANCH_NAME)
	cp docker/template.Dockerfile $(DOCKERFILE)
	sed -i $(DOCKERFILE) -e "s/FROM image:tag/FROM $(IMAGE_NAME):$(IMAGE_TAG)/"
	git add $(DOCKERFILE)
	git commit -m "Update Dockerfile for $@"
	git push origin $(PUSH_BRANCH_NAME) --force

push: $(CONFIGS)

$(CONFIGS):
	git branch -D $(PUSH_BRANCH_NAME) $(PUSH_BRANCH_NAME)_test
	git fetch origin $(PUSH_BRANCH_NAME)_test:$(PUSH_BRANCH_NAME)_test
	git checkout $(PUSH_BRANCH_NAME)_test
	git branch -B $(PUSH_BRANCH_NAME)
	git push origin $(PUSH_BRANCH_NAME) --force
	git branch -D $(PUSH_BRANCH_NAME) $(PUSH_BRANCH_NAME)_test
	git push origin :$(PUSH_BRANCH_NAME)_test
