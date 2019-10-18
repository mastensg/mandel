#include <cstdio>

#include <cuda_profiler_api.h>

__global__ void f(int *x) {
  int i = blockDim.x * blockIdx.x + threadIdx.x;
  if (0 == i % 2) {
    x[i] = i;
  }
  // printf("%d\n",i);
}

int main() {
  // const size_t block_size = 1024;
  // const size_t blocks = 1024;
  const size_t block_size = 4;
  const size_t blocks = 4;
  const size_t n = blocks * block_size;
  const size_t size = n * sizeof(int);

  int *h_x = reinterpret_cast<int *>(malloc(size));

  int *d_x;
  cudaMalloc(&d_x, size);

  f<<<blocks, block_size>>>(d_x);
  // cudaDeviceSynchronize();

  cudaMemcpy(h_x, d_x, size, cudaMemcpyDeviceToHost);

#if 1
  for (size_t i = 0; i < n; ++i) {
    fprintf(stderr, "%3zu %3d\n", i, h_x[i]);
  }
#endif
  // std::fprintf(stderr, "%d\n", h_x[n - 1]);

  cudaProfilerStop();
}
