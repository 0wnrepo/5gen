#
# To use, run:
#   docker build -t 5gen .
#   docker run -it 5gen /bin/bash
#

FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install gcc g++
RUN apt-get -y install autoconf libtool make
RUN apt-get -y install libgmp3-dev libmpfr-dev libmpfr4 libssl-dev
RUN apt-get -y install python python-dev python-setuptools python-numpy
RUN apt-get -y install wget zip

WORKDIR /inst
RUN wget http://flintlib.org/flint-2.5.2.tar.gz
RUN tar xvf flint-2.5.2.tar.gz

WORKDIR /inst/flint-2.5.2
RUN ./configure
RUN make -j8
RUN make install
RUN ldconfig

WORKDIR /inst
RUN git clone https://github.com/5GenCrypto/5gen.git

WORKDIR /inst/5gen
RUN git pull origin master
