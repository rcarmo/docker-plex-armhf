# docker-plex-armhf

Run the Plex media server as a Docker container on the Raspberry Pi or similar hardware

## Status

This is a work in progress that is already usable but which still requires some tweaks

## Quickstart

    sudo make build
    sudo make run

## Requirements

* An `armhf` machine like the Raspberry Pi 2/3 or an ODROID development board
* A Linux distribution that can run Docker (like Ubuntu 16.04.2, which is what I use) with a kernel that supports the `macvlan` network type.

