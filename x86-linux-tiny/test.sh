#!/bin/sh

make clean
make
echo
stat -c %s m
echo
time -p ./m > test
echo
meh test
rm test z
make clean
