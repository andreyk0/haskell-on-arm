# Ubuntu 16.04 LTS
# Linux axps 4.4.0-22-generic #40-Ubuntu SMP Thu May 12 22:03:46 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
# qemu-user-static 1:2.5+dfsg-5ubuntu10.1 amd64 QEMU user mode emulation binaries (static version)
# docker: 1.11.2
#

help:
	@echo
	@echo "make create-armhf-debian-jessie-image  -- base OS docker image"
	@echo "make publish-armhf-debian-jessie-image -- publishes ^^ to registry"
	@echo
	@echo "make create-haskell-platform-armhf-debian-jessie  -- adds packages required to run ghc to base"
	@echo "make publish-haskell-platform-armhf-debian-jessie -- publishes ^^ to registry"
	@echo


# Works well with ghc-7.10.3
LLVM_VERSION=3.5.2
LLVM_TXZ=clang+llvm-$(LLVM_VERSION)-armv7a-linux-gnueabihf.tar.xz
TAG=$(shell date +%Y%m%d)


# Has everything needed to run stack/ghc but not the actual binaries.
# It's easier to manage them in a local directory and mount as a volume into docker.
# Builds a flattened image with intermediate layers merged.
create-haskell-platform-armhf-debian-jessie: \
	docker/haskell-platform-armhf-debian-jessie/$(LLVM_TXZ)

	cd docker/haskell-platform-armhf-debian-jessie/ && docker build -t haskell-platform-armhf-debian-jessie:latest .
	ID=`docker run -d haskell-platform-armhf-debian-jessie:latest /bin/bash` ; \
		 docker export $$ID | docker import - andreyk0/haskell-platform-armhf-debian-jessie:$(TAG) \
		 docker rm $$ID

# Pushes image to docker registry.
publish-haskell-platform-armhf-debian-jessie:
	docker push andreyk0/haskell-platform-armhf-debian-jessie:$(TAG)

# Download version known to work with GHC
docker/haskell-platform-armhf-debian-jessie/$(LLVM_TXZ):
	wget -o $@ http://llvm.org/releases/$(LLVM_VERSION)/$(LLVM_TXZ)


# Creates a base OS docker image from the SD card images.
create-armhf-debian-jessie-image: \
	docker/armhf-debian-jessie/jessie.tgz \
	docker/armhf-debian-jessie/qemu-arm-static

	cd docker/armhf-debian-jessie && docker build -t andreyk0/armhf-debian-jessie:$(TAG) .


publish-armhf-debian-jessie-image:
	docker push andreyk0/armhf-debian-jessie:$(TAG)


# You need qemu-user-static to be installed.
docker/armhf-debian-jessie/qemu-arm-static: /usr/bin/qemu-arm-static
	cp -av $< $@


# Assumes you have these .img files from the SD card, root and boot partitions.
# E.g. as root: cat /dev/sdc1 > root.img
docker/armhf-debian-jessie/jessie.tgz: root.img boot.img
	mkdir -pv /tmp/sdcard
	sudo mount -o loop root.img /tmp/sdcard
	sudo mount -o loop boot.img /tmp/sdcard/boot
	sudo tar czvf `pwd`/$@ -C /tmp/sdcard/ .
	sudo chown `id -u`:`id -g` $@
	sudo umount /tmp/sdcard/boot
	sudo umount /tmp/sdcard
	sudo rmdir /tmp/sdcard
