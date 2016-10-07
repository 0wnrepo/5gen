FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y install git
RUN apt-get -y install gcc-4.9
RUN apt-get -y install autoconf
RUN apt-get -y install libtool
RUN apt-get -y install make
RUN apt-get -y install libgmp3-dev
RUN apt-get -y install libmpfr-dev libmpfr4
RUN apt-get -y install libssl-dev
RUN apt-get -y install python python-dev python-setuptools python-numpy python-networkx
RUN apt-get -y install wget
RUN apt-get -y install g++

WORKDIR /inst
RUN wget http://flintlib.org/flint-2.5.2.tar.gz
RUN tar xvf flint-2.5.2.tar.gz

WORKDIR /inst/flint-2.5.2
RUN ./configure
RUN make -j
RUN make install
RUN ldconfig

WORKDIR /inst
RUN git clone https://github.com/5GenCrypto/5gen.git

WORKDIR /inst/5gen
RUN ./build-ccs.sh
