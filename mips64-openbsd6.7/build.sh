#!/bin/sh -eu

CFLAGS="-march=mips64 -ggdb3"

CC=mips64-unknown-openbsd6.7-egcc

"${CC}" ${CFLAGS} -o mandel mandel.s
