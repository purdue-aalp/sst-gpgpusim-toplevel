# sst-gpgpusim-toplevel
This repo contains all the scripts and setup information to pull various other repositories required to run SST-GPGPU-Sim.

To initially run a simple test vector add program:

```shell
source setup_environment.sh
make run_test
```

After making changes, setup_environment is not necessary, just run:

```shell
make all
make run_test
```

Note that make all recompiles core, which will trigger a full rebuild - so if you only modify one sub-repo (like GPGPU-Sim or sst-elements).
You can just make this sub-repo. Examine Makefile for more details.
