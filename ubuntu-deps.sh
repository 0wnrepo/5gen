#!/usr/bin/env bash
# Build deps for Ubuntu 16.04 when running on Google Compute Engine

apt-get -y update
apt-get -y install autoconf libtool libgmp-dev libmpfr-dev make libssl-dev g++
apt-get -y install python-dev python-setuptools python-numpy python-networkx

wget http://flintlib.org/flint-2.5.2.tar.gz
tar xvf flint-2.5.2.tar.gz

pushd flint-2.5.2
./configure
make -j
make install
ldconfig
popd
