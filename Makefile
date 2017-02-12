build:
	docker build -t rcarmo/plex:armhf .

# Build a Docker network that spans the typical home router address space
# but pin the IP addresses it gives out to the upper range
network:
	docker network create -d macvlan \
	--subnet=192.168.1.0/24 \
        --gateway=192.168.1.254 \
	--ip-range=192.168.1.128/25 \
	-o parent=eth0 \
	lan

shell:
	-mkdir -p /tmp/plex/data
	docker run -v /tmp/plex/data:/srv/plex/data --net=lan -it rcarmo/plex:armhf /bin/bash

run:
	-mkdir -p /tmp/plex/data
	docker run -v /tmp/plex/data:/srv/plex/data --net=lan -it rcarmo/plex:armhf
