#!/usr/bin/env bash

# This example will produce three ciphertexts in database/, and then run an eval 
# on them to determine the output of the 3DNF function.

if [ $# -ne 5 ]; then
   echo "Usage: run-ore.sh <mmap> <λ> <base> <length> <parallel>"
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
if [ "$5" == "0" ]; then
    echo "Disabling parallelism"
    parallel='0'
    pflag='-s'
    ncores='--ncores 1'
else
    parallel='1'
    pflag=''
    ncores=''
fi

DIR="."
export LD_LIBRARY_PATH='../build/lib'

mkdir -p public
mkdir -p private
mkdir -p database
cp $DIR/mbps/3dnf-$base-$length.json $DIR/public/template.json

echo "* Key Generation"
time ../build/bin/keygen $ncores -s $lambda -n $N $mmap
echo "* Encrypt"
time $DIR/3dnf_encrypt -i 1 $mmap $base $length 5 $parallel
echo "* Evaluate"
time ../build/bin/eval $pflag $mmap '{"a":"1","b":"1","c":"1"}'
