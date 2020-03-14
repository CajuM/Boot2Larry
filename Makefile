PWD=$(shell pwd)
IMGNAME=b2l-build

.PHONY: docker all

docker:
	docker build -t $(IMGNAME) docker

all: b2l.iso

b2l.iso: pkgs/fdkernel.zip pkgs/freecom.zip

pkgs/fdkernel.zip:
	docker run -it --rm -v $(PWD)/deps/fdkernel $(IMGNAME) make
