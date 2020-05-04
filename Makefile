KOKKOS_EXE_HOME ?= .

all: sstcore gpgpusim sstelements tests

sstcore:
	make install -C sst-core -j

sstelements:
	make install -C sst-elements -j

gpgpusim:
	make -C sst-gpgpusim -j

vecAdd: sst-tutorial/exercises/vecAdd.cu
	rm -rf run_tests/vectorAdd
	mkdir -p run_tests/vectorAdd
	nvcc sst-tutorial/exercises/vecAdd.cu -o run_tests/vectorAdd/vectorAdd -lcudart

lulesh-tests: sst-tutorial/exercises/lulesh
	mkdir -p run_tests/lulesh/
	cp sst-tutorial/exercises/lulesh run_tests/lulesh/

kokkos-tests: sst-tutorial/exercises/kokkos
	mkdir -p run_tests/kokkos/
	cp $(KOKKOS_EXE_HOME)/KokkosKernels_UnitTest_Cuda run_tests/kokkos/kokkos

run_vecAdd: vecAdd
	cd run_tests/vectorAdd/ && cp -r ../../sst-tutorial/exercises/v100-2SM/* . && mpirun -n 3 sst --partitioner=self --model-option="-c ariel-gpu-v100.cfg -x vectorAdd" --output-config="config.log" --output-partition="partition.log" cuda-test.py 

run_kokkos: kokkos-tests
	cd run_tests/kokkos/ && cp -r ../../sst-tutorial/exercises/v100-2SM/* . && mpirun -n 3 sst --partitioner=self --model-option="-c ariel-gpu-v100.cfg -x kokkos -a gtest_filter=cuda.abs_double" --output-config="config.log" --output-partition="partition.log" cuda-test.py

full_clean:
	rm -rf sst-core
	rm -rf sst-gpgpusim
	rm -rf sst-elements
	rm -rf sst-tutorial
	rm -rf run_tests
	rm -rf openmpi*
