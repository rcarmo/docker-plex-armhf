export IMAGE_NAME=rcarmo/plex:armhf
export SHARES?="//server/share1 //server/share2"
export DATA_FOLDER?=/tmp/plex/data
build:
	docker build -t $(IMAGE_NAME) .

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
		--env PLEX_MOUNT_SHARES=$(SHARES) \
		--net=lan -it $(IMAGE_NAME)

rmi:
	docker rmi -f $(IMAGE_NAME)

push:
	-docker push $(IMAGE_NAME)

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)-docker rmi $(IMAGE_NAME)
