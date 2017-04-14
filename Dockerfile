#
# To use, run:
#   docker build -t 5gen .
#   docker run -it 5gen /bin/bash
#

FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:hvr/ghc
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install gcc g++
RUN apt-get -y install autoconf libtool make
RUN apt-get -y install libgmp3-dev libmpfr-dev libmpfr4 libssl-dev libflint-dev
RUN apt-get -y install python python-dev python-setuptools python-numpy
RUN apt-get -y install wget zip
RUN apt-get -y install cabal-install ghc

#
# Install Z3
#

WORKDIR /inst
RUN wget https://github.com/Z3Prover/z3/archive/z3-4.5.0.tar.gz
RUN tar xf z3-4.5.0.tar.gz
WORKDIR /inst/z3-z3-4.5.0
RUN ./configure
WORKDIR /inst/z3-z3-4.5.0/build
RUN make -j8
RUN make install

#
# Install cryfsm
#

WORKDIR /inst
RUN git clone https://github.com/5GenCrypto/cryfsm.git
WORKDIR /inst/cryfsm
RUN cabal update
RUN cabal sandbox init
RUN cabal install alex
RUN cabal install happy
RUN cabal install
RUN ln .cabal-sandbox/bin/cryfsm /usr/bin/cryfsm
RUN ln .cabal-sandbox/bin/fsmevade /usr/bin/fsmevade
RUN ln .cabal-sandbox/bin/numfsm /usr/bin/numfsm

#
# Get 5gen repository
#

WORKDIR /inst
RUN git clone https://github.com/5GenCrypto/5gen.git
WORKDIR /inst/5gen
CMD git pull origin master
