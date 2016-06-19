# 5Gen 

Repository for building and running applications of multilinear maps, which 
include multi-input functional encryption (MIFE) and obfuscation.

## Instructions

Run the following to build all the libraries needed locally.
```
build.sh
```
(On Ubuntu 14.04, you can use `ubuntu-build.sh` to install all the necessary 
libraries and build the code.)

Before running the below examples, run the following to set up the environment.
```
source setup.sh
```


### Matrix branching program generation

To specify a function for either MIFE or obfuscation, we rely on cryfsm 
(https://github.com/5GenCrypto/cryfsm) to convert the function specification (in 
Cryptol) into a matrix branching program (as a `.json` file).

To run our examples for MIFE and obfuscation, we have generated the necessary 
`.json` files for certain settings of ORE, 3DNF encryption, and point function 
obfuscation.

### Multi-input functional encryption examples

We offer MIFE for the comparison function (also known as order-revealing 
encryption, ORE) and the 3dnf function (which we will call 3DNF).

MIFE consists of three algorithms: keygen, encrypt, and eval. You can run each 
one individually, found in the `build/bin/` directory. You can also execute our 
example scripts for ORE and 3DNF which run all three algorithms.
```
./mife-experiments/run-ore-clt
./mife-experiments/run-3dnf-clt
````
The ciphertexts are by default stored in `database/`, the public key stored in 
`public/`, and the private key stored in `private/`.

### Obfuscation examples

To try our obfuscation examples, run the following.
```
obf-experiments/point.sh <SZ|Z> <secparams> <min> <inc> <max>
````
So, for example, to run Sahai-Zhandry on security parameters 40 and 80 for
point functions of length 8, 12, 16, run:
```
obf-experiments/point.sh SZ CLT "40 80" 8 4 16
````

