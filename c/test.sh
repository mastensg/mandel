#!/bin/sh

set -e

make clean
make
./mandel > test
meh test
