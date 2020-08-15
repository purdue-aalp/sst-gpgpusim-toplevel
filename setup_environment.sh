
GPGPUSIM_REPO=https://github.com/purdue-aalp/sst-gpgpusim
SST_ELEMENTS_REPO=https://github.com/purdue-aalp/sst-elements
BALAR_REPO=https://github.com/purdue-aalp/balar
SST_TUTORIAL_REPO=https://github.com/purdue-aalp/sst-tutorial

if [ ! -n "$PIN_HOME" ]; then
	echo "ERROR ** Install PIN and set PIN_HOME";
	return;
fi

if [ ! -n "$INTEL_PIN_DIRECTORY" ]; then
	echo "ERROR ** Set INTEL_PIN_DIRECTORY";
	return;
fi

if [ ! -n "$CUDA_INSTALL_PATH" ]; then
	echo "ERROR ** Install CUDA Toolkit and set CUDA_INSTALL_PATH.";
	return;
fi

if [ ! -d "$CUDA_INSTALL_PATH" ]; then
	echo "ERROR ** CUDA_INSTALL_PATH=$CUDA_INSTALL_PATH invalid (directory does not exist)";
	return;
fi

# to run the debug build of GPGPU-Sim run:
# source setup_environment debug
NVCC_PATH=`which nvcc`;
if [ $? = 1 ]; then
	echo "";
	echo "ERROR ** nvcc (from CUDA Toolkit) was not found in PATH but required to build GPGPU-Sim.";
	echo "         Try adding $CUDA_INSTALL_PATH/bin/ to your PATH environment variable.";
	echo "         Please also be sure to read the README file if you have not done so.";
	echo "";
	return;
fi

CC_VERSION=`gcc --version | head -1 | awk '{for(i=1;i<=NF;i++){ if(match($i,/^[0-9]\.[0-9]\.[0-9]$/))  {print $i; exit 0}}}'`
if [ "$CC_VERSION" != "4.9.4" ]; then
    echo "WARNING - this setup has only been tested with gcc 4.9.4"
fi

CUDA_VERSION_STRING=`$CUDA_INSTALL_PATH/bin/nvcc --version | awk '/release/ {print $5;}' | sed 's/,//'`;
export CUDA_VERSION_NUMBER=`echo $CUDA_VERSION_STRING | sed 's/\./ /' | awk '{printf("%02u%02u", 10*int($1), 10*$2);}'`
if [ $CUDA_VERSION_NUMBER -gt 9100 -o $CUDA_VERSION_NUMBER -lt 2030  ]; then
	echo "ERROR ** GPGPU-Sim version $GPGPUSIM_VERSION_STRING not tested with CUDA version $CUDA_VERSION_STRING (please see README)";
	return
fi

if [ ! -d "openmpi-4.0.3" ]; then
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.3.tar.gz
    tar xfz openmpi-4.0.3.tar.gz
    cd openmpi-4.0.3
    export MPIHOME=`pwd`
    ./configure --prefix=$MPIHOME
    make all -j
    make install
    export PATH=$MPIHOME/bin:$PATH
    export MPICC=mpicc
    export MPICXX=mpicxx
    export PMIX_MCA_gds=hash
    export LD_LIBRARY_PATH=$MPIHOME/lib:$LD_LIBRARY_PATH
    export DYLD_LIBRARY_PATH=$MPIHOME/lib:$DYLD_LIBRARY_PATH
    export MANPATH=$MPIHOME/share/man:$DYLD_LIBRARY_PATH
    cd ..
fi

# Get and configure sst-core
if [ ! -d "sst-core" ]; then
    git clone https://github.com/sstsimulator/sst-core
    cd sst-core
    export SST_CORE_HOME=`pwd`
    ./autogen.sh
    ./configure --prefix=$SST_CORE_HOME --disable-mem-pools --enable-debug
    make all -j
    make install
    export PATH=$SST_CORE_HOME/bin:$PATH
    cd ../
else
    echo "Assumed sst-core already pulled and built"
fi

# Get and configure gpgpu-sim
if [ ! -d "sst-gpgpusim" ]; then
    git clone $GPGPUSIM_REPO

    cd sst-gpgpusim
    source setup_environment
    make -j
    cd ../
else
    echo "Assumed gpgpu-sim_distribution configured"
fi

# Get and configure sst-elements
if [ ! -d "sst-elements" ]; then
    git clone $SST_ELEMENTS_REPO

    cd sst-elements
    export SST_ELEMENTS_HOME=`pwd`
    cd src/sst/elements
    git clone $BALAR_REPO
    cd ../../..
    ./autogen.sh
    ./configure --prefix=$SST_ELEMENTS_HOME --with-sst-core=$SST_CORE_HOME --with-pin=$PIN_HOME --with-cuda=$CUDA_INSTALL_PATH --with-gpgpusim=$GPGPUSIM_ROOT
    make all
    make install
    cd ../
else
    echo "Assumed sst-elements configured"
fi

# Get and configure the sst-tutorial
if [ ! -d "sst-tutorial" ]; then
    git clone $SST_TUTORIAL_REPO
    cd sst-tutorial
    export SST_TUTORIAL=`pwd`
    cd ..

    mkdir -p run_tests/vectorAdd
else
    echo "Assumed sst-tutorial configured"
fi
