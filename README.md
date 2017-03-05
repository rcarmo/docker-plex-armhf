# docker-plex-armhf

Run the Plex media server as a Docker container on the Raspberry Pi or similar hardware.

## Usage

The usage scenario for this is as follows: I have a very old NAS that is unable to run Plex by itself, so I decided to get Plex running on a Raspberry Pi and mount my media library on it via SMB.

However, since I don't fully trust the Plex binaries and don't want to pollute the host userland, running this in a container lets me keep tabs on it _and_ upgrade it relatively easily in the future.

## Quickstart

First, create a network that maps to your LAN on your Docker host:

	docker network create -d macvlan \
	--subnet=192.168.xxx.0/24 \
        --gateway=192.168.xxx.254 \
	--ip-range=192.168.xxx.128/25 \
	-o parent=eth0 \
	lan

Then start the image (use `-d` to leave it running as a daemon), specifying which remote SMB shares to mount:

    docker run -v /your/data/path:/srv/plex/data \
    --cap-add SYS_ADMIN \
    --cap-add DAC_READ_SEARCH \
    --env PLEX_MOUNT_SHARES="//server1/folder //server2/folder" \
    --net=lan -it rcarmo/plex:armhf

## Requirements

* An `armhf` machine like the Raspberry Pi 2/3 or an ODROID development board
* A Linux distribution that can run Docker (like Ubuntu 16.04.2, which is what I use) with a kernel that supports the `macvlan` network type.

