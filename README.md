# mmap-experiments

Repository for building and running experiments on the multilinear map applications of multi-input functional encryption and obfuscation.

## Instructions


Run the following to build all the libraries needed locally.
```
build.sh
```
(On Ubuntu, you can use `commands.sh` to install all the necessary libraries and build the code.)

Before running the below experiments, run the following to set up the environment.
```
source setup.sh
```

### Multi-input functional encryption experiments

TODO

### Obfuscation experiments

To run the obfuscation experiments, run the following.
```
obf-experiments/point.sh <SZ|Z> <secparams> <min> <inc> <max>
````
So, for example, to run Sahai-Zhandry on security parameters 40 and 80 for
point functions of length 8, 12, 16, run:
```
obf-experiments/point.sh SZ "40 80" 8 4 16
````
