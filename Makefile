.SILENT:
.PHONY: image config

ifeq ($(UBUNTU_VERSION),)
$(error Please set UBUNTU_VERSION)
endif

image: config
	docker pull ubuntu:$(UBUNTU_VERSION)
	cd out/$(UBUNTU_VERSION) && docker build --no-cache --rm --force-rm --tag zedaav/ubuntu-box:$(UBUNTU_VERSION) .

config:
	rm -Rf out/$(UBUNTU_VERSION)
	mkdir -p out/$(UBUNTU_VERSION)
	cp -a docker/* out/$(UBUNTU_VERSION)
	sed -i out/$(UBUNTU_VERSION)/Dockerfile -e "s/{tag}/$(UBUNTU_VERSION)/"
