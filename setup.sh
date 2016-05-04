builddir=$(readlink -f build)
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
