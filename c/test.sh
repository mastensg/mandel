#!/bin/sh

set -e

make clean
make
time -p ./mandel > test
meh test
