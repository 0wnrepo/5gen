#!/usr/bin/env bash

#abort if any command fails
set -e

echo "libaesrand"
	path=libaesrand
	url=https://github.com/5GenCrypto/libaesrand.git
    if [ ! -d $path ]; then
        git clone $url;
    fi
    cd $path; git pull origin master; git checkout c3b5077; cd ..;

echo "clt13"
	path=clt13
	url=https://github.com/5GenCrypto/clt13.git
    if [ ! -d $path ]; then
        git clone $url;
    fi
    cd $path; git pull origin master; git checkout cfa5bda; cd ..;

echo "gghlite-flint"
	path=gghlite-flint
	url=https://github.com/5GenCrypto/gghlite-flint.git
    if [ ! -d $path ]; then
        git clone $url;
    fi
    cd $path; git pull origin master; git checkout 77ec8a0; cd ..;

echo "obfuscation"
	path=obfuscation
	url=https://github.com/5GenCrypto/obfuscation.git
    if [ ! -d $path ]; then
        git clone $url;
    fi
    cd $path; git pull origin master; git checkout 1b1429b; cd ..;

echo "libmmap"
	path=libmmap
	url=https://github.com/5GenCrypto/libmmap
    if [ ! -d $path ]; then
        git clone $url;
    fi
    cd $path; git pull origin master; git checkout ee8c6aa; cd ..;

echo "mife"
	path=mife
	url=https://github.com/5GenCrypto/mife
    if [ ! -d $path ]; then
        git clone $url;
    fi
    cd $path; git pull origin master; git checkout 20bdf70; cd ..;

mkdir -p build
builddir=$(readlink -f build)

export CPPFLAGS=-I$builddir/include
export CFLAGS=-I$builddir/include
export LDFLAGS=-L$builddir/lib

echo builddir = $builddir

echo building libaesrand
cd libaesrand
    autoreconf -i
    ./configure --prefix=$builddir
    make -j
    make install
cd ..

echo building clt13
cd clt13
    mkdir -p build/autoconf
    autoreconf -i
    ./configure --prefix=$builddir
    make -j
    make install
cd ..

echo building gghlite-flint
cd gghlite-flint
    autoreconf -i
    ./configure --prefix=$builddir
    make -j
    make install
cd ..

echo building libmmap
cd libmmap
    autoreconf -i
    ./configure --prefix=$builddir
    make -j
    make install
cd ..

echo building mife
cd mife
    git submodule init
    git submodule update
    mkdir -p build/autoconf
    autoreconf -i
    ./configure --prefix=$builddir
    sed '/all:/i install:' mife/jsmn/Makefile > tmp-jsmn-makefile
    mv tmp-jsmn-makefile mife/jsmn/Makefile
    make -j
    make install
cd ..

echo building obfuscation
cd obfuscation
    autoreconf -i
    ./configure --prefix=$builddir
    make -j
    make install
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
    export PYTHONPATH="$builddir/lib/python2.7/site-packages:$builddir/lib64/python2.7/site-packages"
    python2 setup.py test
    mkdir -p $builddir/lib/python2.7/site-packages
    mkdir -p $builddir/lib64/python2.7/site-packages
    python2 setup.py install --prefix=$builddir
cd ..

cat << EOF > $builddir/bin/run-obfuscator
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
export PYTHONPATH="$builddir/lib/python2.7/site-packages:$builddir/lib64/python2.7/site-packages"
$builddir/bin/obfuscator "\$@"
EOF
chmod 755 $builddir/bin/run-obfuscator
