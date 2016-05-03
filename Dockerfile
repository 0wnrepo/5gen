FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN apt-get -y install git
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y install gcc-4.9
RUN apt-get -y install autoconf
RUN apt-get -y install libtool
RUN apt-get -y install make
RUN apt-get -y install libgmp3-dev
RUN apt-get -y install libmpfr-dev libmpfr-doc libmpfr4 libmpfr4-dbg
RUN apt-get -y install libssl-dev
RUN apt-get -y install python
RUN apt-get -y install wget

WORKDIR /bin
RUN wget http://flintlib.org/flint-2.5.2.tar.gz
RUN tar xvf flint-2.5.2.tar.gz
WORKDIR flint-2.5.2
RUN ./configure
RUN make
RUN make install

WORKDIR /bin
RUN git clone https://github.com/kevinlewi/mmap-experiments.git
WORKDIR mmap-experiments

RUN ./build.sh
