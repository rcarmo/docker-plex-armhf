FROM armv7/armhf-debian:jessie
MAINTAINER Rui Carmo https://github.com/rcarmo

# Update the system and set up the ReadyNAS repository
RUN apt-get update && apt-get dist-upgrade -y && apt-get install \
    apt-transport-https \
    wget \
    -y --force-yes  \
 && wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | apt-key add - \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Plex and move its data directory to someplace sensible
RUN echo "deb https://dev2day.de/pms/ jessie main" | tee /etc/apt/sources.list.d/pms.list \
 && apt-get update && apt-get install plexmediaserver -y \
 && mkdir -p /srv/plex/data \
 && chown plex:nogroup /srv/plex/data \
 && cd /var/lib/plexmediaserver/Library/Application\ Support \
 && rm -rf Plex\ Media\ Server \
 && ln -s /srv/plex/data Plex\ Media\ Server \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose mounts and ports
VOLUME /srv/plex/data
VOLUME /tmp
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
ENV PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000
ENV PLEX_MEDIA_SERVER_TMPDIR=/tmp
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/srv/plex/data
ENV LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}"
WORKDIR /srv/plex/data

CMD ulimit -s $PLEX_MAX_STACK_SIZE; \
    (cd $PLEX_MEDIA_SERVER_HOME; ./Plex\ Media\ Server)
