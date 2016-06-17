# ubuntu:14.04, cloned from Dockerfile

apt-get -y update
apt-get -y install software-properties-common
apt-get -y install git
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get -y install gcc-4.9
apt-get -y install autoconf
apt-get -y install libtool
apt-get -y install make
apt-get -y install libgmp3-dev
apt-get -y install libmpfr-dev libmpfr4
apt-get -y install libssl-dev
apt-get -y install python python-dev python-setuptools python-numpy python-networkx
apt-get -y install wget
apt-get -y install g++

cd /bin
wget http://flintlib.org/flint-2.5.2.tar.gz
tar xvf flint-2.5.2.tar.gz

cd flint-2.5.2
./configure
make -j
make install
ldconfig

cd /bin
git clone https://github.com/5GenCrypto/5gen.git

cd 5gen
./build.sh
