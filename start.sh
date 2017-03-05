#!/bin/bash

for share in $PLEX_MOUNT_SHARES
do
	basename=`basename $share`
	echo Mounting $share as /mnt/$basename
	rm -rf /mnt/$basename
	mkdir /mnt/$basename
	mount -t cifs -o user=guest,ro,password="" $share /mnt/$basename
done

ulimit -s $PLEX_SERVER_MAX_STACK_SIZE
ulimit -m $PLEX_SERVER_MAX_RSS
ulimit -m $PLEX_SERVER_MAX_VM
cd $PLEX_MEDIA_SERVER_HOME
./Plex\ Media\ Server
