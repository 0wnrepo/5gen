#!/usr/bin/env bash

if [ $# -ne 4 ]; then
   echo "Usage: run-ore.sh <mmap> <λ> <base> <length>"
   exit 1
fi

if [ "$1" != "CLT" ] && [ "$1" != "GGH" ]; then
    echo "Error: mmap must be either CLT or GGH"
    exit 1
fi

if [ "$1" == "CLT" ]; then
    mmap='-C'
else
    mmap=''
fi
lambda=$2
base=$3
length=$4
N=8

mkdir -p public
mkdir -p private
mkdir -p database
cp mbps/ore-$base-$length.json public/template.json

echo "* Key Generation"
time ../build/bin/keygen -s $lambda -n $N $mmap
echo "* Encrypt"
time ./ore_encrypt -i 1 $mmap $base $length 5
echo "* Evaluate"
time ../build/bin/eval $mmap '{"a":"1","b":"1"}'
