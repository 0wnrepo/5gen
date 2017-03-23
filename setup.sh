#!/usr/bin/env bash

builddir=$(readlink -f build)
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$builddir/lib"
export PYTHONPATH="$PYTHONPATH:$builddir/lib/python2.7/site-packages:$builddir/lib64/python2.7/site-packages"
