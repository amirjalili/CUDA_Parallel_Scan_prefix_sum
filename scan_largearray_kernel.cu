#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>


#define NUM_BANKS 16
#define LOG_NUM_BANKS 4
#define TILE_SIZE 1024
// You can use any other block size you wish.
#define BLOCK_SIZE 512


// Host Helper Functions (allocate your own data structure...)


// Device Functions



// Kernel Functions

__global__ void scan(unsigned int *outArray, unsigned int *inArray, unsigned int *sumArray, int numElements){
    
    // shared memory size: 2 * Block_size
    __shared__ unsigned int scanArray[TILE_SIZE];
    int index = blockIdx.x*TILE_SIZE + threadIdx.x;
   
    // Load elements to shared memory
    if(index < numElements && (threadIdx.x!=0 || blockIdx.x!=0))
        scanArray[threadIdx.x] = inArray[index-1];
    else
        scanArray[threadIdx.x] = 0;
    
    if(index+BLOCK_SIZE < numElements)
        scanArray[threadIdx.x + BLOCK_SIZE] = inArray[index-1 + BLOCK_SIZE];
    else
        scanArray[threadIdx.x + BLOCK_SIZE] = 0;


    // prescan operation    
    unsigned int id, stride;
    for(stride=1;stride<TILE_SIZE;stride *= 2){
        __syncthreads();
        id = (threadIdx.x+1) * 2 * stride - 1;
        if(id<TILE_SIZE)
            scanArray[id] += scanArray[id-stride];
    }

    // Post scan
    for( stride=BLOCK_SIZE/2; stride>0; stride /= 2){
        id = (threadIdx.x+1) * 2 * stride - 1;
        if(id + stride < TILE_SIZE)
            scanArray[id+stride] += scanArray[id];
        __syncthreads();
    }
    
    __syncthreads();
    if(threadIdx.x==0)
        sumArray[blockIdx.x] = scanArray[TILE_SIZE-1];
    if(index < numElements)
        outArray[index] = scanArray[threadIdx.x];
    if(index + BLOCK_SIZE < numElements)
        outArray[index+BLOCK_SIZE] = scanArray[threadIdx.x+BLOCK_SIZE]; 
    
}

// Kernel function to perform vector addition of the Auxiliary arrax on the output elements
__global__ void vectorAddition(unsigned int *vector, unsigned int *sumVector, int numElements){
    int index = blockIdx.x*TILE_SIZE + threadIdx.x;
    if(index < numElements){
        vector[index] += sumVector[blockIdx.x];
    }
    if(index + BLOCK_SIZE < numElements){
        vector[index + BLOCK_SIZE] += sumVector[blockIdx.x];
    }
}


// **===-------- Modify the body of this function -----------===**
// You may need to make multiple kernel calls. Make your own kernel
// functions in this file, and then call them from here.
// Note that the code has been modified to ensure numElements is a multiple 
// of TILE_SIZE
void prescanArray(unsigned int *outArray, unsigned int *inArray, int numElements)
{
     
    unsigned int *sumArray;
    int blocks = (int)ceil(numElements/(float)TILE_SIZE);
    cudaMalloc((void**) &sumArray, sizeof(unsigned int)*blocks);

    scan<<<blocks, BLOCK_SIZE>>>(outArray, inArray, sumArray, numElements);
    if (blocks > 1) {
        prescanArray(sumArray, sumArray, blocks);

        vectorAddition<<<blocks, BLOCK_SIZE>>>(outArray, sumArray, numElements);
    }
    cudaFree(sumArray);
}
// **===-----------------------------------------------------------===**


#endif // _PRESCAN_CU_
