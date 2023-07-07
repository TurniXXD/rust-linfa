# Script for installing libtorch from scratch (without any python dependencies)
# This clones the ``pytorch`` folder in the current directory, creates a ``pytorch-build`` directory containing all the intermediate files for building, and creates a ``pytorch-install`` folder for storing the compiled library.
# After the build, you can use it by setting ``CMAKE_PREFIX_PATH=(path to pytorch-install folder)``.
# Note that you need to have all the dependencies needed before running this script! (Read README.md in the main pytorch repo)

git clone --recursive https://github.com/pytorch/pytorch -b v1.7.1 --depth 1

mkdir -p pytorch-build
mkdir -p pytorch-install
pushd pytorch-build

# There are a lot of CMake flags, but I'll just go over the important ones. (I'm not completely sure about these flags, note that I've copied most of them from the PKGBUILD from the Arch Linux package repo.)
# BUILD_CUSTOM_PROTOBUF: You can use this to use the Protobuf library installed on your system instead of what is included in the pytorch source.
#                        This is sometimes very important; In my case I had a dependency in my project needing a different version of Protobuf, and it collided (quite spectacularily) from the one provided by libtorch.
# BUILD_PYTHON: Use this to enable/disable compiling everything related to Python.
# BUILD_DISTRIBUTED: Set this to enable torch.distributed support.
# USE_SYSTEM_NCCL: Set this to use a system-installed NCCL rather than the one provided by pytorch. 
# NCCL_VERSION: Version of nccl. If pkg-config doesn't work for your OS, then you can just enter this manually.
# CUDA_HOME: This specifies the CUDA directory. Note that this is for Arch Linux; it will be different for other OSs such as Ubuntu/CentOS, and will depend on how you've installed CUDA on your system!
# TORCH_CUDA_ARCH_LIST: This specifies the list of Nvidia architectures you're compiling for. If you use a recent GPU, chances are that you only need to include some of those versions.
# USE_CUDA / USE_CUDNN: Use it to turn on/off CUDA support.
# USE_NATIVE_ARCH: When set to ON, it will compile with all architectural optimizations for your CPU enabled. (For example, AVX, AVX2, AVX512, etc...)
#                  Recommend if you're using a recent CPU with special AVX/AVX512 instructions, and if you don't need portable builds.
# Note that there might be some unnecessary flags turned on. Tweak this depending on your system and requirements.

cmake -DUSE_MKLDNN=ON \
      -DBUILD_CUSTOM_PROTOBUF=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DUSE_FFMPEG=ON \
      -DUSE_GFLAGS=ON \
      -DUSE_GLOG=ON \
      -DBUILD_BINARY=ON \
      -DBUILD_PYTHON=OFF \
      -DBUILD_TEST=OFF \
      -DPYTHON_LIBRARY='' \
      -DUSE_OPENCV=ON \
      -DUSE_SYSTEM_NCCL=ON \
      -DUSE_DISTRIBUTED=ON \
      -DNCCL_VERSION=$(pkg-config nccl --modversion) \
      -DNCCL_VER_CODE=$(sed -n 's/^#define NCCL_VERSION_CODE\s*\(.*\).*/\1/p' /usr/include/nccl.h) \
      -DCUDAHOSTCXX=g++ \
      -DCUDA_HOME=/opt/cuda \
      -DCUDNN_LIB_DIR=/usr/lib \
      -DCUDNN_INCLUDE_DIR=/usr/include \
      -DTORCH_CUDA_ARCH_LIST="5.2;5.3;6.0;6.1;6.2;7.0;7.0+PTX;7.2;7.2+PTX;7.5;7.5+PTX;8.0;8.0+PTX;8.6;8.6+PTX" \
      -DUSE_CUDA=OFF \
      -DUSE_CUDNN=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=../pytorch-install \
      -GNinja \
      ../pytorch
      
# We're using ninja to speed up builds. Note that this will take quite some time (it will be good to have a beefy CPU!)
ninja install

popd