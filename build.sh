#!/usr/bin/env bash

set -e

if [ "$1" == "debug" ]; then
    echo "DEBUG mode"
    debugflag='--enable-debug'
elif [ "$1" == "clean" ]; then
    rm -rf build libaesrand clt13 gghlite libmmap mife obfuscation
    exit 0
elif [ "$1" == "paper" ]; then
    # Commits used for producing numbers in https://eprint.iacr.org/2016/619
    libaesrand=c3b5077
    clt13=cfa5bda
    gghlite=77ec8a0
    libmmap=ee8c6aa
    obfuscation=1b1429b
    mife=20bdf70
elif [ "$1" == "help" ]; then
    echo "$0: 5Gen build script"
    echo ""
    echo "Commands:"
    echo "  <default>  Build everything"
    echo "  debug      Build in debug mode"
    echo "  clean      Remove build"
    echo "  paper      Build using commits used to reproduce results in ePrint version"
    echo "  help       Print this info and exit"
    exit 0
else
    debugflag=""
fi

mkdir -p build
builddir=$(readlink -f build)
echo builddir = "$builddir"

export CPPFLAGS=-I$builddir/include
export CFLAGS=-I$builddir/include
export LDFLAGS=-L$builddir/lib

pull () {
    path=$1
    url=$2
    branch=$3
    if [ ! -d "$path" ]; then
        git clone "$url" "$path"
    fi
    pushd "$path"
    git pull origin "$branch"
    if [ x"$4" != x"" ]; then
        git checkout "$4"
    fi
    popd
}

build () {
    path=$1
    pushd "$path"
    mkdir -p build/autoconf
    if [ ! -e configure ]; then
        autoreconf -i
    fi
    ./configure --prefix="$builddir" $debugflag
    make -j8
    # make check
    make install
    popd
}

pull libaesrand  https://github.com/5GenCrypto/libaesrand    master $libaesrand
pull clt13       https://github.com/5GenCrypto/clt13         master $clt13
pull gghlite     https://github.com/5GenCrypto/gghlite-flint master $gghlite
pull libmmap     https://github.com/5GenCrypto/libmmap       master $libmmap
pull mife        https://github.com/5GenCrypto/mife          master $mife
pull obfuscation https://github.com/5GenCrypto/obfuscation   master $obfuscation

build libaesrand
build clt13
build gghlite
build libmmap
pushd mife
    git submodule init
    git submodule update
    mkdir -p build/autoconf
    if [ ! -e configure ]; then autoreconf -i; fi
    ./configure --prefix="$builddir" $debugflag
    sed '/all:/i install:' mife/jsmn/Makefile > tmp-jsmn-makefile
    mv tmp-jsmn-makefile mife/jsmn/Makefile
    make -j8
    make install
popd
pushd obfuscation
    mkdir -p build/autoconf
    if [ ! -e configure ]; then autoreconf -i; fi
    ./configure --prefix="$builddir" $debugflag
    make -j8
    make install
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
    export PYTHONPATH="$builddir/lib/python2.7/site-packages:$builddir/lib64/python2.7/site-packages"
    python2 setup.py test
    mkdir -p "$builddir/lib/python2.7/site-packages"
    mkdir -p "$builddir/lib64/python2.7/site-packages"
    python2 setup.py install --prefix="$builddir"
popd

cat << EOF > "$builddir/bin/run-obfuscator"
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
export PYTHONPATH="$builddir/lib/python2.7/site-packages:$builddir/lib64/python2.7/site-packages"
$builddir/bin/obfuscator "\$@"
EOF
chmod 755 "$builddir/bin/run-obfuscator"
