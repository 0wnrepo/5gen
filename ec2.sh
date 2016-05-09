# ubuntu:14.04, cloned from Dockerfile

sudo apt-get -y update
sudo apt-get -y install software-properties-common
sudo apt-get -y install git
sudo apt-get -y install gcc
sudo apt-get -y install autoconf
sudo apt-get -y install libtool
sudo apt-get -y install make
sudo apt-get -y install libgmp3-dev
sudo apt-get -y install libmpfr-dev libmpfr4
sudo apt-get -y install libssl-dev
sudo apt-get -y install python python-dev python-setuptools python-numpy python-networkx
sudo apt-get -y install wget
sudo apt-get -y install g++

wget http://flintlib.org/flint-2.5.2.tar.gz
tar xvf flint-2.5.2.tar.gz

pushd flint-2.5.2
./configure
make -j
sudo make install
sudo ldconfig
popd

./build.sh

# set up ore-experiments
cp build/bin/keygen ore-experiments/
cp build/bin/encrypt ore-experiments/
cp build/bin/eval ore-experiments/
