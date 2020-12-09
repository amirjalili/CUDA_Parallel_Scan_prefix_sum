# CUDA_Parallel_Scan_prefix_sum

# Overview
This is an implementation of a work-efficient parallel prefix-sum algorithm on the GPU. The algorithm is also called scan. Scan is a useful building block for many parallel algorithms, such as radix sort, quicksort, tree operations, and histograms. Exclusive scan applied to an Array A will produce an Array A', where:

A′[i] =A′[i−1] +A[i−1] :A[0] = 0

Or 

A′[i] =∑i−1j=0A[j] :A[0] = 0

While scan is an appropriate algorithm for any associative operator, this implementation uses addition. More details about this algorithm can be found in [Mark Harris' report](https://developer.nvidia.com/gpugems/gpugems3/part-vi-gpu-computing/chapter-39-parallel-prefix-sum-scan-cuda).


# Execution

* Run "make" to build the executable of this file.
* For debugging, run "make dbg=1" to build a debuggable version of the executable binary.
* Run the binday using the command "./scan_largearray"

There are several modes of operation for the application -

* No arguments: Randomly generate input data and compare the GPU's result against the host's result. 
* One argument: Randomly generate input data and write the result to the file specified by the argument.
* Two arguments: The first argument specifies a file that contains the array size. Randomly generate input data and write it to the file specified by the second argument. (This mode is good for generating test arrays.)
* Three arguments: The first argument specifies a file that contains the array size. The second and third arguments specify the input file and output file, respectively.

Note that if you wish to use the output of one run of the application as an input, you must delete the first line in the output file, which displays the accuracy of the values within the file.
