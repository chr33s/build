DIST = debian 
VER  = 8.3.0
TAG  = ${DIST}/${VER}

build:
	@packer build -only=virtualbox-iso ${DIST}/packer.json

import:
	@vagrant box add ${TAG} ${DIST}-${VER}-virtualbox.box

up: build import

rebuild:
	@vagrant box remove ${TAG} || true
	build

install:
	@vagrant plugin install vagrant-cachier vagrant-vbguest

uninstall:
	@vagrant destroy -f
	@vagrant box remove ${TAG} 

clean:
	@rm -rf packer_cache
	@rm -rf *.box

.PHONY: build import install uninstall clean
.DEFAULT: up
