KOKKOS_EXE_HOME=../kokkos-top-level/

all: sstcore gpgpusim sstelements tests

sstcore:
	make install -C sst-core -j

sstelements: 
	make install -C sst-elements -j

gpgpusim:
	make -C sst-gpgpusim -j

vecAdd: sst-tutorial/exercises/vecAdd.cu
	rm -rf run_tests/vectorAdd
	mkdir -p run_tests/vectorAdd/vectorAdd
	nvcc sst-tutorial/exercises/vecAdd.cu -o run_tests/vectorAdd/vectorAdd/vectorAdd -lcudart

tests: sst-tutorial/exercises/vecAdd.cu
	mkdir -p run_tests/vectorAdd/
	nvcc sst-tutorial/exercises/vecAdd.cu -o run_tests/vectorAdd/vectorAdd -lcudart

lulesh-tests: sst-tutorial/exercises/lulesh
	mkdir -p run_tests/lulesh/
	cp sst-tutorial/exercises/lulesh run_tests/lulesh/

kokkos-tests: sst-tutorial/exercises/kokkos
	mkdir -p run_tests/kokkos/
	cp $(KOKKOS_EXE_HOME)/KokkosKernels_UnitTest_Cuda run_tests/kokkos/kokkos

bfs-tests: sst-tutorial/exercises/bfs
	mkdir -p run_tests/bfs/
	cp sst-tutorial/exercises/bfs run_tests/bfs/
	cp sst-tutorial/exercises/graph*.txt run_tests/bfs/

run_vecAdd: vecAdd
	cd run_tests/vectorAdd/ && cp -r ../../sst-tutorial/exercises/v100-vecAdd/* . && sst --model-option="-c ariel-gpu-v100.cfg" --output-config="python file" cuda-test.py

debug_vecAdd: vecAdd
	cd run_tests/vectorAdd/ && cp -r ../../sst-tutorial/exercises/v100-vecAdd/* . && gdb --args sst --model-option="-c ariel-gpu-v100.cfg" --output-config="python file" cuda-test.py

run_vecAdd_parallel: vecAdd
	cd run_tests/vectorAdd/ && cp -r ../../sst-tutorial/exercises/v100-vecAdd-parallel/* . && sst --model-option="-c ariel-gpu-v100.cfg" --output-config="python file" cuda-test.py

debug_vecAdd_parallel: vecAdd
	cd run_tests/vectorAdd/ && cp -r ../../sst-tutorial/exercises/v100-vecAdd-parallel/* . && gdb --args sst --model-option="-c ariel-gpu-v100.cfg" --output-config="python file" cuda-test.py

run_vecAdd_dis: vecAdd
	cd run_tests/vectorAdd/ && cp -r ../../sst-tutorial/exercises/v100-vecAdd-parallel-dis/* . && mpirun -n 2 sst --partitioner=self --model-option="-c ariel-gpu-v100.cfg" --output-config="python file" --output-partition="partition.log" cuda-test.py

run_kokkos: kokkos-tests
	cd run_tests/kokkos/ && cp -r ../../sst-tutorial/exercises/v100-kokkos/* . && sst --model-option="-c ariel-gpu-v100.cfg -a gtest_filter=cuda.abs_double" --output-config="python file" cuda-test.py

run_kokkos_parallel: kokkos-tests
	cd run_tests/kokkos/ && cp -r ../../sst-tutorial/exercises/v100-kokkos-parallel/* . && sst --model-option="-c ariel-gpu-v100.cfg -a gtest_filter=cuda.abs_double" --output-config="python file" cuda-test.py

debug_kokkos_parallel: kokkos-tests
	cd run_tests/kokkos/ && cp -r ../../sst-tutorial/exercises/v100-kokkos-parallel/* . && gdb --args sst --model-option="-c ariel-gpu-v100.cfg -a gtest_filter=cuda.abs_double" --output-config="python file" cuda-test.py

#run_test: tests
#	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem-volta-cramsim/* . && sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py
#
#run_test_parallel: tests
#	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST_DIS/* . && cp ../../sst-tutorial/exercises/volta-cramsim-parallel/* . && sst -n 1 --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" --output-partition="partition.log" cuda-test.py
#
#debug_test_parallel: tests
#	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST_DIS/* . && cp ../../sst-tutorial/exercises/volta-cramsim-parallel/* . && gdb --args sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py
#
#run_test_simple_mem: tests
#	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem-volta/* . && sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py
#
#debug_test: tests
#	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem-volta/* . && gdb --args sst --model-option="-c ariel-gpu-titanV.cfg" cuda-test.py
#
#run_test_lulesh: lulesh-tests
#	cd run_tests/lulesh/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-lulesh/* . && sst --model-option="-c ariel-gpu.cfg" cuda-test.py
#
#run_test_kokkos: kokkos-tests
#	cd run_tests/kokkos/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem-volta-kokkos/* . && sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py
#
#run_test_kokkos_parallel: kokkos-tests
#	cd run_tests/kokkos/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST_DIS/* . && cp ../../sst-tutorial/exercises/volta-cramsim-parallel-kokkos/* . && sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py
#
#debug_test_kokkos: kokkos-tests
#	cd run_tests/kokkos/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem-volta-kokkos/* . && gdb --args sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py
#
#debug_test_kokkos_parallel: kokkos-tests
#	cd run_tests/kokkos/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST_DIS/* . && cp ../../sst-tutorial/exercises/volta-cramsim-parallel-kokkos/* . && gdb --args sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py
#
#run_test_bfs: bfs-tests
#	cd run_tests/bfs/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem-volta-bfs/* . && sst --model-option="-c ariel-gpu-titanV.cfg" --output-config="python file" cuda-test.py

full_clean:
	rm -rf sst-core
	rm -rf sst-gpgpusim
	rm -rf sst-elements
	rm -rf sst-tutorial
	rm -rf run_tests
	rm -rf openmpi*
