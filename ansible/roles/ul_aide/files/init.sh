#!/bin/bash

FILEFLAG=/var/lib/aide/.init

if [ ! -f $FILEFLAG ]; then
    nice -n 19 /usr/sbin/aide --init && \
    mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz && \
    touch $FILEFLAG
fi
