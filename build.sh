#!/usr/bin/env bash

#abort if any command fails
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

echo building libaesrand
cd libaesrand
    ./configure --prefix=$builddir
    make
    make install
cd ..

echo building clt13
cd clt13
    mkdir -p build/autoconf
    autoreconf -i
    ./configure --prefix=$builddir
    make
    make install
cd ..

echo building gghlite-flint
cd gghlite-flint
    autoreconf -i
    ./configure --prefix=$builddir
    make -j
    make install
cd ..

cd libmmap
    autoreconf -i
    ./configure --prefix=$builddir
    make
    make install
cd ..

cd mife
    git submodule init
    git submodule update
    mkdir -p build/autoconf
    autoreconf -i
    ./configure --prefix=$builddir
    sed '/all:/i install:' mife/jsmn/Makefile > tmp-jsmn-makefile
    mv tmp-jsmn-makefile mife/jsmn/Makefile
    make
    make install
cd ..

cd obfuscation
    autoreconf -i
    ./configure --prefix=$builddir
    make
    make install
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
    export PYTHONPATH="$builddir/lib/python2.7/site-packages"
    python2 setup.py test
    mkdir -p $builddir/lib/python2.7/site-packages
    python2 setup.py install --prefix=$builddir
cd ..

cat << EOF > $builddir/bin/run-obfuscator
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
export PYTHONPATH="$builddir/lib/python2.7/site-packages"
$builddir/bin/obfuscator "\$@"
EOF
chmod 755 $builddir/bin/run-obfuscator
