#!/usr/bin/env bash
set -e

if [ $# -ne 4 ]; then
    echo "Usage: point.sh <mmaps> <secparams> <points> <nthreads>"
    exit 1
fi

ext='json'

for mmap in $1; do
    if [ "$mmap" != "CLT" ] && [ "$mmap" != "GGH" ]; then
        echo "Error: mmap must be either CLT or GGH"
        exit 1
    fi
done

if [ ! -d "build" ]; then
    echo "Error: build directory missing"
    echo "Are you running from the base of the repo?"
    exit 1
fi

mmaps=$1
secparams=$2
points=$3
nthreads=$4

BIN="build/bin/run-obfuscator"
DIR="obf-experiments"
CIRCUIT_DIR="$DIR/mbps"
LOG_DIR="$DIR/results"

TIME=`date +"%F__%H-%M-%S"`
mkdir -p "$LOG_DIR/point-$TIME"

echo "**************************************************************"
echo "* Running point functions: $points"
echo "* Security parameters: $secparams"
echo "* Multilinear maps: $mmaps"
echo "* Number of threads: $nthreads"
echo "**************************************************************"
echo ""

for secparam in $secparams; do
    echo "** security parameter: $secparam"
    for point in $points; do
        circuit="point-$point.$ext"
        echo "**** circuit: $circuit"
        for mmap in $mmaps; do
            echo "****** multilinear map: $mmap"
            dir="$LOG_DIR/point-$TIME/$secparam/$point/$mmap/$nthreads"
            mkdir -p "$dir"
            obf=$circuit.obf.$secparam
            eval=`sed -n 1p $CIRCUIT_DIR/$circuit | awk '{ print $3 }'`

	    cat << EOF > script.py
try:
    print('$point'.split('-')[1])
except:
    print('2')
EOF
	    base=`python script.py`
	    rm script.py

            # obfuscate
            $BIN obf \
                 --load $CIRCUIT_DIR/$circuit \
                 --secparam $secparam \
                 --mmap $mmap \
                 --nthreads $nthreads \
                 --verbose 2> $dir/obf-time.log
            # get size of obfuscation
            du --bytes $CIRCUIT_DIR/$obf/* > $dir/obf-size.log
            # evaluate
            $BIN obf \
                 --load-obf $CIRCUIT_DIR/$obf \
                 --eval $eval \
                 --mmap $mmap \
		         --base $base \
                 --verbose 2> $dir/eval-time.log
            $DIR/extract-all.py $dir
            # cleanup
            rm -rf $CIRCUIT_DIR/$circuit.obf.$secparam
        done
    done
done

# zip -q -r results-$TIME.zip $LOG_DIR
