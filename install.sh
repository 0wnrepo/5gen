# abort if any command fails
set -e

git submodule init
git submodule update

mkdir -p build
builddir=$(realpath build)

export CPPFLAGS=-I$builddir/include
export CFLAGS=-I$builddir/include
export CPPFLAGS=-I$builddir/include
export LDFLAGS=-L$builddir/lib

echo builddir = $builddir

cd libaesrand
    ./configure --prefix=$builddir
    make
    make install
cd ..

cd clt13
    mkdir -p build/autoconf
    autoreconf -i
    ./configure --prefix=$builddir
    make
    make install
cd ..

cd gghlite-flint
    git submodule init
    git submodule update
    autoreconf -i
    ./configure --prefix=$builddir
    sed '/all:/i install:' mife/jsmn/Makefile > tmp-jsmn-makefile
    mv tmp-jsmn-makefile mife/jsmn/Makefile
    make -j
    make install
cd ..

cd obfuscation
    autoreconf -i
    ./configure --prefix=$builddir
    make
    make install
    python2 setup.py test
cd ..
