source /usr/local/gpgpu-sim-setup/sst_8.0_env_setup.sh

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

CC_VERSION=`gcc --version | head -1 | awk '{for(i=1;i<=NF;i++){ if(match($i,/^[0-9]\.[0-9]\.[0-9]$/))  {print $i; exit 0}}}'`
if [ "$CC_VERSION" != "4.8.2" ]; then
    echo "WARNING - this setup has only been tested with gcc 4.8.2"
fi

CUDA_VERSION_STRING=`$CUDA_INSTALL_PATH/bin/nvcc --version | awk '/release/ {print $5;}' | sed 's/,//'`;
export CUDA_VERSION_NUMBER=`echo $CUDA_VERSION_STRING | sed 's/\./ /' | awk '{printf("%02u%02u", 10*int($1), 10*$2);}'`
if [ $CUDA_VERSION_NUMBER -gt 9100 -o $CUDA_VERSION_NUMBER -lt 2030  ]; then
	echo "ERROR ** GPGPU-Sim version $GPGPUSIM_VERSION_STRING not tested with CUDA version $CUDA_VERSION_STRING (please see README)";
	return
fi

cd sst-core
export SST_CORE_HOME=`pwd`
export PATH=$SST_CORE_HOME/bin:$PATH
cd ../

cd sst-gpgpusim
source setup_environment
cd ../

cd sst-elements
export SST_ELEMENTS_HOME=`pwd`
export LD_LIBRARY_PATH=$SST_ELEMENTS_HOME/src/sst/elements/Gpgpusim/:$LD_LIBRARY_PATH
export SST_ELEMENTS_CONFIG="1"
cd ../