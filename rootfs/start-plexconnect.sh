#!/bin/bash -e

# ignore Plex libraries
unset LD_LIBRARY_PATH

PLEX_VOLUME=/srv/plex/data
PLEXCONNECT_DATA=${PLEX_VOLUME}/PlexConnect
PLEXCONNECT_ROOT=/opt/PlexConnect
PLEXCONNECT_LOGPATH=${PLEXCONNECT_DATA}

mkdir -p ${PLEXCONNECT_DATA}
cd ${PLEXCONNECT_DATA}

if [ ! -f trailers.cer ]; then
  echo "Generating SSL certificate"
  openssl req -new -nodes -newkey rsa:2048 \
    -out trailers.pem -keyout trailers.key \
    -x509 -days 7300 -subj "/C=US/CN=trailers.apple.com"
  openssl x509 -in trailers.pem -outform der -out trailers.cer \
    && cat trailers.key >> trailers.pem
fi

cp trailers.* ${PLEXCONNECT_ROOT}/assets/certificates/

rm -f ${PLEXCONNECT_ROOT}/*.cfg
echo [PlexConnect] > Settings.cfg
env | grep ^PLEXCONNECT_ | sed -E -e 's/^PLEXCONNECT_//' -e 's/(.*)=/\L\1 = /' >> Settings.cfg

cd ${PLEXCONNECT_ROOT}

ln -s ${PLEXCONNECT_DATA}/Settings.cfg

if [ ! -f ATVSettings.cfg ]; then
  ln -s ${PLEXCONNECT_DATA}/ATVSettings.cfg
fi
python PlexConnect.py
