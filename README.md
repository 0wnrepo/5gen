# 5Gen 

Repository for building and running applications of multilinear maps, which 
include multi-input functional encryption (MIFE) and obfuscation.

## Instructions

### Install locally

Run the following to build all the libraries needed locally:
```
./build.sh
```
`build.sh` has three options: `debug` builds in debug mode, `clean` cleans up the repository,
and `paper` uses the same commits that were used to produce the numbers in https://eprint.iacr.org/2016/619.

Before running the below examples, run the following to set up the environment.
```
source setup.sh
```

### Install through docker

Run the following to build all the libraries needed using docker:
```
docker build -t mbpobf .
```
You can then enter the docker container using:
```
docker run -it mbpobf /bin/bash
```
Now, within the docker container, follow the instructions in the "Install locally" section above.

### Matrix branching program generation

To specify a function for either MIFE or obfuscation, we rely on cryfsm 
(https://github.com/5GenCrypto/cryfsm) to convert the function specification (in 
Cryptol) into a matrix branching program (as a `.json` file).

To run our examples for MIFE and obfuscation, we have generated the necessary 
`.json` files for certain settings of ORE, 3DNF encryption, and point function 
obfuscation.

### Producing numbers from paper

To reproduce the numbers from the 5Gen paper, run `build.sh paper`, `source setup.sh`, and `runall.sh`.

