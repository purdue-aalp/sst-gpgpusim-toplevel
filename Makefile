all: sstcore gpgpusim sstelements tests

sstcore:
	make -C sst-core all -j
	make install -C sst-core

sstelements: sstcore gpgpusim
	make -C sst-elements all -j
	make -C sst-elements install

gpgpusim:
	sh ./gpgpu-sim_distribution/setup_environment
	make -C gpgpu-sim_distribution -j

tests:
	mkdir -p tests
	nvcc sst-tutorial/exercises/vecAdd.cu -o tests/vectorAdd/vectorAdd
