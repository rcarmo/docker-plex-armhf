FROM armv7/armhf-debian:jessie
MAINTAINER Rui Carmo https://github.com/rcarmo

ARG DEBIAN_FRONTEND="noninteractive"
ENV TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"

# Update the system and set up the ReadyNAS repository
RUN apt-get update && apt-get dist-upgrade -y && apt-get install \
    apt-transport-https \
    cifs.utils \
    git \
    python-pil \
    supervisor \
    wget \
    -y --force-yes  \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Plex and move its data directory to someplace sensible
RUN echo "deb https://dev2day.de/pms/ jessie main" | tee /etc/apt/sources.list.d/pms.list \
 && wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | apt-key add - \
 && apt-get update && apt-get install plexmediaserver -y \
 && mkdir -p /srv/plex/data \
 && chown plex:nogroup /srv/plex/data \
 && cd /var/lib/plexmediaserver/Library/Application\ Support \
 && rm -rf Plex\ Media\ Server \
 && ln -s /srv/plex/data Plex\ Media\ Server \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add configuration files and scripts
ADD rootfs /

# Install and patch PlexConnect
RUN cd /opt \
 && git clone https://github.com/iBaa/PlexConnect.git 

# Expose mounts and ports
VOLUME /srv/plex/data
VOLUME /tmp
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
ENV PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000
ENV PLEX_MEDIA_SERVER_MAX_RSS=1024
ENV PLEX_MEDIA_SERVER_MAX_VM=1024
ENV PLEX_MEDIA_SERVER_TMPDIR=/tmp
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/srv/plex/data
ENV LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}"
WORKDIR /srv/plex/data

EXPOSE 53 80 443 32400

# Startup script
CMD ["/usr/bin/supervisord"]

# Labels
ARG VCS_REF
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/rcarmo/docker-plex-armhf"
