#!/usr/bin/env bash

# This example will produce three ciphertexts in database/, and then run an eval 
# on them to determine the output of the 3DNF function.

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

DIR="."
export LD_LIBRARY_PATH='../build/lib'

mkdir -p public
mkdir -p private
mkdir -p database
cp $DIR/mbps/3dnf-$base-$length.json $DIR/public/template.json

echo "* Key Generation"
time ../build/bin/keygen -s $lambda -n $N $mmap
echo "* Encrypt"
time $DIR/3dnf_encrypt -i 1 $mmap $base $length 5
echo "* Evaluate"
time ../build/bin/eval $mmap '{"a":"1","b":"1","c":"1"}'
