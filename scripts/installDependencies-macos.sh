#!/bin/bash
# This script installs all external dependencies

checkLastSuccess() {
  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]]; then
    echo "Install Error: $1"
    exit 1
  fi
}

# install grpc and related components
# 1. install cares
CARES=$(find /usr -name '*c-ares*')
if [ -z "$CARES" ]; then
  cd ~/temp/grpc/third_party/cares/cares &&
    CXX=g++-7 CC=gcc-7 cmake -DCMAKE_BUILD_TYPE=Debug &&
    make && make install
  checkLastSuccess "install cares fails"
else
  echo "c-ares has been installed, skip"
fi
# 2. install protobuf
PROTOBUF=$(protoc --version | grep "3.6")
if [ -z "$PROTOBUF" ]; then
  cd ~/temp/grpc/third_party/protobuf/cmake &&
    mkdir -p build && cd build &&
    # use cmake instead of autogen.sh so that protobuf-config.cmake can be installed
    CXX=g++-7 CC=gcc-7 cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Debug .. &&
    make && make install && make clean && ldconfig
  checkLastSuccess "install protobuf fails"
else
  echo "protobuf v3.6 has been installed, skip"
fi
# 3. install grpc
# install libssl-dev to skip installing boringssl
GRPC=$(grep "1.16" /usr/local/lib/cmake/grpc/gRPCConfigVersion.cmake)
if [ -z "$GRPC" ]; then
  cd ~/temp/grpc &&
    sed -i -E "s/\(gRPC_ZLIB_PROVIDER.*\)module\(.*CACHE\)/\1package\2/" CMakeLists.txt &&
    sed -i -E "s/\(gRPC_CARES_PROVIDER.*\)module\(.*CACHE\)/\1package\2/" CMakeLists.txt &&
    sed -i -E "s/\(gRPC_SSL_PROVIDER.*\)module\(.*CACHE\)/\1package\2/" CMakeLists.txt &&
    sed -i -E "s/\(gRPC_PROTOBUF_PROVIDER.*\)module\(.*CACHE\)/\1package\2/" CMakeLists.txt &&
    CXX=g++-7 CC=gcc-7 cmake -DCMAKE_BUILD_TYPE=Debug &&
    make && make install && make clean && ldconfig
  checkLastSuccess "install grpc fails"
else
  echo "gRPC v1.16 has been installed, skip"
fi

