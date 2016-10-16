#!/usr/bin/env bash

small=40
big=80

# obfuscation
echo "**************************************************************"
echo "* Running obfuscation experiments                            *"
echo "**************************************************************"
echo "CLT $small 6-16 0"
./obf-experiments/point.sh CLT $small 6-16 0
echo "CLT $small 7-29 0"
./obf-experiments/point.sh CLT $small 7-29 0
echo "CLT $big 8-27 0"
./obf-experiments/point.sh CLT $big   8-27 0
echo "GGH $small 9-13 0"
./obf-experiments/point.sh GGH $small 9-13 0
echo "GGH $small 6-31 0"
./obf-experiments/point.sh GGH $small 6-31 0

# ore experiments
echo "**************************************************************"
echo "* Running ORE experiments                                    *"
echo "**************************************************************"
pushd mife-experiments
echo "CLT $small 4 18"
./run-ore.sh CLT $small 4 18
du -h
./clean.sh
echo "CLT $small 4 21"
./run-ore.sh CLT $small 4 21
du -h
./clean.sh
echo "GGH $small 4 18"
./run-ore.sh GGH $small 4 18
du -h
./clean.sh
echo "GGH $small 4 21"
./run-ore.sh GGH $small 4 21
du -h
./clean.sh
echo "CLT $big 4 18"
./run-ore.sh CLT $big   4 18
du -h
./clean.sh
echo "CLT $big 4 21"
./run-ore.sh CLT $big   4 21
du -h
./clean.sh
echo "GGH $big 4 18"
./run-ore.sh GGH $big   4 18
du -h
./clean.sh
echo "GGH $big 5 19"
./run-ore.sh GGH $big   5 19
du -h
./clean.sh
popd

# 3dnf experiments
echo "**************************************************************"
echo "* Running 3DNF experiments                                   *"
echo "**************************************************************"
pushd mife-experiments
echo "CLT $small 4 16"
./run-3dnf.sh CLT $small 4 16
du -h
./clean.sh
echo "CLT $big 4 16"
./run-3dnf.sh CLT $big   4 16
du -h
./clean.sh
echo "GGH $small 4 16"
./run-3dnf.sh GGH $small 4 16
du -h
./clean.sh
echo "GGH $big 4 16"
./run-3dnf.sh GGH $big   4 16
du -h
./clean.sh
popd
