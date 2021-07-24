#!/bin/sh

UNIT_DIR=/run/systemd/generator

MOUNT_ROOT=/mnt/samba

SAMBA_HOST=//samba

SAMBA_DIRS="
    android
    anime
    anime-old
    backup
    books
    comedy
    documentaries
    download
    emulation
    games
    images
    incoming-media
    josh
    kids
    lectures
    movie-sets
    movies
    movies-4khdr
    movies-old
    movies-sd
    music
    music-lossless
    playlists
    ps2
    ps3
    public
    switch
    tv
    tv-incoming
    videos
    vmstore
    www
"

REQUIRES_DIR="$UNIT_DIR/remote-fs.target.requires"


make_mount_unit(){
cat << EOF
[Unit]
Description=samba mount: $1
Requires=systemd-networkd.service
After=network-online.target
Wants=network-online.target

[Mount]
What=${SAMBA_HOST}/$1
Where=${MOUNT_ROOT}/$1
Options=credentials=/root/.smbcredentials,iocharset=utf8,rw,x-systemd.automount,uid=1000
Type=cifs
TimeoutSec=30

[Install]
WantedBy=multi-user.target
EOF
}


make_automount_unit(){
cat << EOF
[Unit]
Description=samba automount: $1
Requires=network-online.target
Before=remote-fs.target

[Automount]
Where=${MOUNT_ROOT}/$1
TimeoutIdleSec=0

[Install]
WantedBy=multi-user.target
EOF
}


if [ ! -e "$REQUIRES_DIR" ]; then mkdir "$REQUIRES_DIR"; fi


make_units(){
    mount_file=$(/usr/bin/systemd-escape -p --suffix=mount "${MOUNT_ROOT}/$1")
    automount_file=$(/usr/bin/systemd-escape -p --suffix=automount "${MOUNT_ROOT}/$1")
    make_mount_unit $1 > "$UNIT_DIR/$mount_file"
    make_automount_unit $1 > "$UNIT_DIR/$automount_file"
    ln -s "../${automount_file}" "$REQUIRES_DIR/"
}


for path in $SAMBA_DIRS; do
    make_units $path
done

