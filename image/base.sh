#!/usr/bin/env bash
set -e
source /build/buildconfig
set -x

# Upgrade all packages.
apt-get update
apt-get dist-upgrade -y --no-install-recommends

# Determine the list of packages required for the base image.
dpkg -l | grep ^ii | sed 's_  _\t_g' | cut -f 2 >/tmp/base.txt

# Install HTTPS support for APT.
$minimal_apt_get_install apt-transport-https ca-certificates

# Install add-apt-repository
$minimal_apt_get_install software-properties-common

# Install curl, needed below for manual BIRD install.
$minimal_apt_get_install curl

# Find the list of packages just installed - these can be deleted later.
grep -Fxvf  /tmp/base.txt <(dpkg -l | grep ^ii | sed 's_  _\t_g' | cut \
-f 2) >/tmp/add-apt.txt

# Add new repos and update again
LC_ALL=C.UTF-8 LANG=C.UTF-8 add-apt-repository -y ppa:cz.nic-labs/bird
apt-get update

# Install packages that should not be removed in the cleanup processing.
# - bird and bird6
# - packages required by felix
# - pip (which includes various setuptools package discovery).
#apt-get install -qy \
$minimal_apt_get_install \
        bird \
        bird6 \
        iptables \
        ipset \
        conntrack \
        net-tools \
        python-pip=1.5.4-1

# Copy patched BIRD daemon with tunnel support.
curl -L https://www.dropbox.com/s/xjhfckzse25x554/bird-6af4e30d3fccb0c6bd184e9168294c807e1e6d68?dl=1 -o /usr/sbin/bird && \
    chmod +x /usr/sbin/bird