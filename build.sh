#!/usr/bin/env bash

set -e

if [ "$1" == "debug" ]; then
    echo "DEBUG mode"
    debugflag='--enable-debug'
else
    debugflag=''
fi

mkdir -p build
builddir=$(readlink -f build)
echo builddir = $builddir

export CPPFLAGS=-I$builddir/include
export CFLAGS=-I$builddir/include
export LDFLAGS=-L$builddir/lib

pull () {
    path=$1
    url=$2
    branch=$3
    if [ ! -d $path ]; then
        git clone $url $path
    fi
    pushd $path
        git pull origin $branch
        if [ "$4" != "" ]; then
            git checkout $4
        fi
    popd
}

build () {
    path=$1
    pushd $path
        mkdir -p build/autoconf
        autoreconf -i
        ./configure --prefix=$builddir $debugflag
        make -j
        # make check
        make install
    popd
}

pull libaesrand  https://github.com/5GenCrypto/libaesrand    master
pull clt13       https://github.com/5GenCrypto/clt13         master
pull gghlite     https://github.com/5GenCrypto/gghlite-flint master
pull libmmap     https://github.com/5GenCrypto/libmmap       master
pull mife        https://github.com/5GenCrypto/mife          master
pull obfuscation https://github.com/5GenCrypto/obfuscation   master

build libaesrand
build clt13
build gghlite
build libmmap
pushd mife
    git submodule init
    git submodule update
    mkdir -p build/autoconf
    autoreconf -i
    ./configure --prefix=$builddir $debugflag
    sed '/all:/i install:' mife/jsmn/Makefile > tmp-jsmn-makefile
    mv tmp-jsmn-makefile mife/jsmn/Makefile
    make -j
    make install
popd
pushd obfuscation
    mkdir -p build/autoconf
    autoreconf -i
    ./configure --prefix=$builddir $debugflag
    make -j
    make install
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
    export PYTHONPATH="$builddir/lib/python2.7/site-packages:$builddir/lib64/python2.7/site-packages"
    python2 setup.py test
    mkdir -p $builddir/lib/python2.7/site-packages
    mkdir -p $builddir/lib64/python2.7/site-packages
    python2 setup.py install --prefix=$builddir
popd

cat << EOF > $builddir/bin/run-obfuscator
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
export PYTHONPATH="$builddir/lib/python2.7/site-packages:$builddir/lib64/python2.7/site-packages"
$builddir/bin/obfuscator "\$@"
EOF
chmod 755 $builddir/bin/run-obfuscator
