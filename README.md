# docker-plex-armhf

Run the Plex media server and PlexConnect as a Docker container on the Raspberry Pi or similar hardware.

## Usage

The usage scenario for this is as follows: I have a very old NAS that is unable to run Plex by itself, so I decided to get Plex running on a Raspberry Pi and mount my media library on it via SMB.

However, since I don't want to pollute the host userland, running this in a container lets me keep tabs on it _and_ upgrade it relatively easily in the future.

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
    --env PLEX_MOUNT_SHARES="/mnt/local://server1/remote //server1/folderA //server2/folderB" \
    --net=lan -it rcarmo/plex:armhf

Note that:

* You can specify `local:remote` pairs to mount a folder
* A remote share called `folder` will be mounted on `/mnt/folder`

## Requirements

* An `armhf` machine like the Raspberry Pi 2/3 or an ODROID development board.
* A Linux distribution that can run Docker (like Ubuntu 16.04.2, which is what I use) with a kernel that supports the `macvlan` network type.

## PlexConnect Setup on Apple TV 3 (up to 7.2.2, at least)

* Go to the Apple TV settings menu
* Set the DNS IP address to that of this container
* Select General then scroll the cursor down to highlight "Send Data To Apple" and set to "No".
* With "Send Data To Apple" highlighted, press "Play" (not the normal Select button) and you will be prompted to add a profile.
* Enter `http://trailers.apple.com/trailers.cer`

## Changelog

* 2017-09-17 Updated Plex to 1.8.4.4249
* 2017-09-02 Updated Plex to 1.8.1.4139
