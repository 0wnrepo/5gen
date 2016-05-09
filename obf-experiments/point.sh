#!/usr/bin/env bash
set -e

if [ $# -ne 5 ]; then
    echo "Usage: point.sh <SZ|Z> <secparams> <min> <inc> <max>"
    exit 1
fi

if [ "$1" = "SZ" ]; then
    scheme='--sahai-zhandry'
    mmaps='CLT GGH'
    exts='circ json'
elif [ "$1" = "Z" ]; then
    scheme='--zimmerman'
    mmaps='CLT'
    exts='acirc'
else
    echo "Error: '$1' invalid"
    echo "Usage: point.sh <SZ|Z> <secparams>"
    exit 1
fi

if [ ! -d "build" ]; then
    echo "Error: build directory missing"
    echo "Are you running from the base of the repo?"
    exit 1
fi

SECPARAMS=$2
MIN=$3
INC=$4
MAX=$5

if [ "$INC" = "0" ]; then
    echo "Error: because we are using 'seq', <inc> cannot be set to 0"
    exit 1
fi

BIN="build/bin/run-obfuscator"
DIR="obf-experiments"
CIRCUIT_DIR="$DIR/circuits"
LOG_DIR="$DIR/results"

TIME=`date +"%F__%H-%M-%S"`
mkdir -p "$LOG_DIR/point-$TIME"

echo "**************************************************************"
echo "* Running point functions: $(seq $MIN $INC $MAX | tr '\n' ' ')"
echo "* Security parameters: $SECPARAMS"
echo "* Scheme: $1"
echo "**************************************************************"
echo ""

for secparam in $SECPARAMS; do
    echo "** security parameter: $secparam"
    for point in `seq $MIN $INC $MAX`; do
        for ext in $exts; do
            # pushd $CIRCUIT_DIR
            # ./point.py $point
            # ./point-json.py $point
            # popd
            circuit="point-$point.$ext"
            echo "**** circuit: $circuit"
            for mmap in $mmaps; do
                echo "****** multilinear map: $mmap"
                dir="$LOG_DIR/point-$TIME/$secparam/$point/$circuit/$mmap"
                mkdir -p $dir
                obf=$circuit.obf.$secparam
                eval=`sed -n 1p $CIRCUIT_DIR/$circuit | awk '{ print $3 }'`

                # obfuscate
                $BIN obf \
                     --load $CIRCUIT_DIR/$circuit \
                     --secparam $secparam \
                     --mlm $mmap \
                     $scheme \
                     --verbose 2> $dir/obf-time.log
                # get size of obfuscation
                du --bytes $CIRCUIT_DIR/$obf/* > $dir/obf-size.log
                # evaluate
                $BIN obf \
                     --load-obf $CIRCUIT_DIR/$obf \
                     --eval $eval \
                     --mlm $mmap \
                     $scheme \
                     --verbose 2> $dir/eval-time.log
                # cleanup
                rm -rf $CIRCUIT_DIR/$circuit.obf.$secparam
            done
        done
    done
done

zip -r results-$TIME.zip $LOG_DIR
