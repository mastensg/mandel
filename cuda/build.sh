#!/bin/sh -eu

CFLAGS="--compiler-options -Wall,-Wextra,-O0,-g"
CUFLAGS="--gpu-architecture=sm_50"

#nvcc ${CFLAGS} ${CUFLAGS} -cubin -o main.cubin main.cu
nvcc ${CFLAGS} ${CUFLAGS} -o mandel main.cu
