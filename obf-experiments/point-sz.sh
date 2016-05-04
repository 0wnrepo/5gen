#!/usr/bin/env bash
set -e

BIN="build/bin/run-obfuscator"
DIR="obf-experiments"
CIRCUIT_DIR="$DIR/circuits"
LOG_DIR="$DIR/runs"

TIME=`date +"%F__%H-%M-%S"`
mkdir -p "$LOG_DIR/point-$TIME"

#
# Change below as needed
#

###########################
SECPARAMS="8 16"
MIN=8
MAX=16
INC=4
###########################

echo "* Running point functions ($MIN -> $MAX)"

for secparam in $SECPARAMS; do
    echo "** security parameter: $secparam"
    for point in `seq $MIN $INC $MAX`; do
        for circuit in "point-$point.circ" "point-$point.json"; do
            echo "**** circuit: $circuit"
            for mmap in CLT GGH; do
                echo "****** multilinear map: $mmap"
                dir="$LOG_DIR/point-$TIME/$secparam/$point/$circuit/$mmap"
                mkdir -p $dir
                obf=$circuit.obf.$secparam
                eval=`python -c "print('0' * $point)"`

                # obfuscate
                $BIN obf \
                     --load $CIRCUIT_DIR/$circuit \
                     --secparam $secparam \
                     --mlm $mmap \
                     --sahai-zhandry \
                     --verbose 2> $dir/obf-time.log
                # get size of obfuscation
                du --bytes $CIRCUIT_DIR/$obf/* > $dir/obf-size.log
                # evaluate
                $BIN obf \
                     --load-obf $CIRCUIT_DIR/$obf \
                     --eval $eval \
                     --mlm $mmap \
                     --sahai-zhandry \
                     --verbose 2> $dir/eval-time.log
                # cleanup
                rm -rf $CIRCUIT_DIR/$circuit.obf.$secparam
            done
        done
    done
done
