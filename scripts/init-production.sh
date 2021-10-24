#!/bin/sh -ex

##
## Setup script for chroot for building hotfix packages
## for production (when the production APT repository is used
## and build result is added to the prod-experimental APT repository).
##

export DEBIAN_FRONTEND=noninteractive

APT_HOST=$1
APT_KEY=$2

if [ ! -z "$APT_HOST" ] && [ ! -z "$APT_KEY" ]; then
    apt-get update
    apt-get install -y wget
    wget -q -O - http://$APT_HOST/$APT_KEY |  apt-key add - && \
        cat > /etc/apt/sources.list.d/dbd-keep.list <<EOF
deb http://$APT_HOST/ production main non-free
EOF
fi

cat > /etc/apt/sources.list.d/backports-keep.list <<EOF
deb http://ftp.debian.org/debian buster-backports main
EOF

cat > /etc/apt/preferences.d/kindustries-keep.pref <<EOF
Package: golang golang-*
Pin: release a=buster-backports
Pin-Priority: 500
EOF

apt-get update
apt-get --purge --auto-remove -y -o 'Dpkg::Options::=--force-confnew' dist-upgrade
apt-get install -y golang qt5-default