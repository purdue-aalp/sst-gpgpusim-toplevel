all: sstcore gpgpusim sstelements tests

sstcore:
	make install -C sst-core -j

sstelements: 
	make install -C sst-elements -j

gpgpusim:
	make -C gpgpu-sim_distribution -j

tests: sst-tutorial/exercises/vecAdd.cu
	mkdir -p run_tests/vectorAdd/
	nvcc sst-tutorial/exercises/vecAdd.cu -o run_tests/vectorAdd/vectorAdd

lulesh-tests: sst-tutorial/exercises/lulesh
	mkdir -p run_tests/lulesh/
	cp sst-tutorial/exercises/lulesh run_tests/lulesh/

run_test: tests
	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem/* . && sst --model-option="-c ariel-gpu.cfg" cuda-test.py

debug_test: tests
	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-gpu-mem/* . && gdb --args sst --model-option="-c ariel-gpu.cfg" cuda-test.py

run_test_lulesh: lulesh-tests
	cd run_tests/lulesh/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV_SST/* . && cp ../../sst-tutorial/exercises/cuda-test-lulesh/* . && sst --model-option="-c ariel-gpu.cfg" cuda-test.py

full_clean:
	rm -rf sst-core
	rm -rf gpgpu-sim_distribution
	rm -rf sst-elements
	rm -rf sst-tutorial
	rm -rf run_tests
