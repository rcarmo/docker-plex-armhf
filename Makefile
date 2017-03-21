export IMAGE_NAME=rcarmo/plex:armhf
export SHARES?="//server/share1 //server/share2"
export RO_SHARES?="//server/share3"
export DATA_FOLDER?=/srv/plex/data
export VCS_REF=`git rev-parse --short HEAD`
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
build:
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		-t $(IMAGE_NAME) .

# Build a Docker network that spans the typical home router address space
# but pin the IP addresses it gives out to the upper range
network:
	docker network create -d macvlan \
	--subnet=192.168.1.0/24 \
        --gateway=192.168.1.254 \
	--ip-range=192.168.1.128/25 \
	-o parent=eth0 \
	lan

# Debug stuff
shell:
	-mkdir -p $(DATA_FOLDER)
	docker run -v $(DATA_FOLDER):/srv/plex/data --net=lan -it $(IMAGE_NAME) /bin/bash

# Run this (for testing)
run:
	-mkdir -p $(DATA_FOLDER)
	docker run -v $(DATA_FOLDER):/srv/plex/data \
		--cap-add SYS_ADMIN \
		--cap-add DAC_READ_SEARCH \
		--env PLEX_MOUNT_READONLY_SHARES=$(SHARES) \
		--net=lan -it $(IMAGE_NAME)

daemon-local-data:
	-mkdir -p $(DATA_FOLDER)
	docker run -h plex-container \
		-v $(DATA_FOLDER):/srv/plex/data \
		--cap-add SYS_ADMIN \
		--cap-add DAC_READ_SEARCH \
		--env PLEX_MOUNT_READONLY_SHARES=$(RO_SHARES) \
		--net=lan -d --restart unless-stopped $(IMAGE_NAME)

daemon-remote-data:
	docker run -h plex-container \
		-e PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=$(DATA_FOLDER) \
		--cap-add SYS_ADMIN \
		--cap-add DAC_READ_SEARCH \
		--env PLEX_MOUNT_WRITABLE_SHARES=$(SHARES) \
		--env PLEX_MOUNT_READONLY_SHARES=$(RO_SHARES) \
		--net=lan -d --restart unless-stopped $(IMAGE_NAME)
rmi:
	docker rmi -f $(IMAGE_NAME)

push:
	-docker push $(IMAGE_NAME)

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $(IMAGE_NAME)
