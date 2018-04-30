.SILENT:
.PHONY: image

image:
	docker build --no-cache --rm --force-rm --tag zedaav/ubuntu-box:latest .
