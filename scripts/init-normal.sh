#!/bin/sh -ex

##
## Setup script for chroot for building normal packages
## (when staging APT repository is used and build result
## is added to the experimental APT repository).
##

APT_HOST=$1
APT_KEY=$2

if [ ! -z "$APT_HOST" ] && [ ! -z "$APT_KEY" ]; then
    apt-get update
    apt-get install -y wget gnupg
    wget -q -O - http://$APT_HOST/$APT_KEY |  apt-key add - && \
        cat > /etc/apt/sources.list.d/dbd-keep.list <<EOF
deb http://$APT_HOST/ staging main non-free
EOF
fi

cat > /etc/apt/sources.list.d/backports-keep.list <<EOF
deb http://ftp.debian.org/debian buster-backports main
EOF

cat > /etc/apt/preferences.d/kindustries-keep.pref <<EOF
Package: golang golang-go golang-src golang-doc
 golang-goprotobuf-dev golang-github-dgrijalva-jwt-go-dev
Pin: release a=buster-backports
Pin-Priority: 500
EOF

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get --purge --auto-remove -y -o 'Dpkg::Options::=--force-confnew' dist-upgrade
apt-get install -y brz ca-certificates git mercurial subversion
apt-get install -y golang golang-go golang-src golang-doc
apt-get install -y golang-goprotobuf-dev golang-github-dgrijalva-jwt-go-dev
apt-get install -y qt5-default