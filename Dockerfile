FROM armv7/armhf-debian:jessie
MAINTAINER Rui Carmo https://github.com/rcarmo

# Update the system and set up the ReadyNAS repository
RUN apt-get update && apt-get dist-upgrade -y && apt-get install \
    apt-transport-https \
    wget \
    cifs.utils \
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
ENV PLEX_MEDIA_SERVER_MAX_RSS=1024
ENV PLEX_MEDIA_SERVER_MAX_VM=1024
ENV PLEX_MEDIA_SERVER_TMPDIR=/tmp
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/srv/plex/data
ENV LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}"
WORKDIR /srv/plex/data

# Startup script
ADD start.sh /start.sh
CMD /start.sh

# Labels
ARG VCS_REF
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/rcarmo/docker-plex-armhf"
