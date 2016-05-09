#!/usr/bin/env bash
set -e

if [ $# -ne 3 ]; then
    echo "Usage: encoding_count.sh <min> <inc> <max>"
    echo -e "\tNote: assumes you have cryfsm installed"
    exit 1
fi

MIN=$1
INC=$2
MAX=$3

if [ "$INC" = "0" ]; then
    echo "Error: because we are using 'seq', <inc> cannot be set to 0"
    exit 1
fi
    
source setup.sh

for length in `seq $MIN $INC $MAX`; do
    ./obfuscation/circuits/point.py $length
    ./obfuscation/circuits/point-json.py $length

    generic=`./obfuscation/obfuscator bp --load point-$length.circ --print | tail -1 | awk '{ print $4 }'`
    cryfsm=`./obfuscation/obfuscator bp --load point-$length.json --print | tail -1 | awk '{ print $4 }'`

    echo $length $generic $cryfsm

    rm point-$length.circ point-$length.acirc point-$length.json
done    
