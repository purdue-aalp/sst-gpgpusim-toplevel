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

run_test: tests
	cd run_tests/vectorAdd/ && cp $(GPGPUSIM_ROOT)/configs/4.x-cfgs/SM7_TITANV/* . && cp ../../sst-tutorial/exercises/cuda-test/* . && sst --model-option="-c ariel.cfg" cuda-test.py

full_clean:
	rm -rf sst-core
	rm -rf gpgpu-sim_distribution
	rm -rf sst-elements
	rm -rf sst-tutorial
	rm -rf run_tests
