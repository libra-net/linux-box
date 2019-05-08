.SILENT:
.PHONY: images configs all

# Supported versions (all LTS + latest)
VERSIONS := 16.04 18.04 latest 19.04
CONFIGS := $(foreach TAG,$(VERSIONS),docker/$(TAG).Dockerfile)
IMAGES := $(foreach TAG,$(VERSIONS),image_$(TAG))
CURTAG = $(subst image_,,$(subst docker/,,$(subst .Dockerfile,,$@)))

all: configs images

configs: $(CONFIGS)

$(CONFIGS): docker/template.Dockerfile
	cp docker/template.Dockerfile $@
	sed -i $@ -e "s/{tag}/$(CURTAG)/"

images: $(IMAGES)

image_%:
	cd docker && docker build -f ./$(CURTAG).Dockerfile --pull --no-cache --rm --force-rm --tag libra-net/ubuntu-box:$(CURTAG) .
