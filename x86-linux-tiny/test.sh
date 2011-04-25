#!/bin/sh

make clean
make
echo
time -p ./m > test
echo
meh test
rm test z
make clean
