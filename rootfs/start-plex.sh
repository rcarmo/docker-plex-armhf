#!/bin/bash

for share in $PLEX_MOUNT_READONLY_SHARES
do
    IFS=':' read local remote <<< "$share"
    if [[ -z $remote ]]; then
        remote=$local
        local=/mnt/`basename $local`
    fi
    echo Mounting $remote as $local - read-only
    mkdir -p $local
    mount -t cifs -o user=guest,ro,password="" $remote $local
done

for share in $PLEX_MOUNT_WRITABLE_SHARES
do
    IFS=':' read local remote <<< "$share"
    if [[ -z $remote ]]; then
        remote=$local
        local=/mnt/`basename $local`
    fi
    echo Mounting $remote as $local - writable
    mkdir -p $local
    mount -t cifs -o user=guest,password="" $remote $local
done

ulimit -s $PLEX_SERVER_MAX_STACK_SIZE
ulimit -m $PLEX_SERVER_MAX_RSS
ulimit -m $PLEX_SERVER_MAX_VM

# Remove PID file in case we were forcibly restarted
rm -f $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex\ Media\ Server/plexmediaserver.pid

cd $PLEX_MEDIA_SERVER_HOME
./Plex\ Media\ Server
