#!/bin/bash

echo "Building with Chromium version: ${CHROMIUM_VERSION}"
echo "Using libcronet version: ${LIBCRONET_VERSION}"

# 获取当前工作目录的路径
CURRENT_DIR="$(pwd)"

# 设置脚本遇到错误即停止执行
set -e

## Fix directory structure
sudo mkdir -p /usr/local/lib && \
    sudo chown -R $(whoami) /usr/local/lib
# copy libcronet
#sudo cp -v ${CURRENT_DIR}/cronet_build/libcronet*dylib /usr/local/lib

export CPPFLAGS="-I${CURRENT_DIR}/cronet_build/include"
export LDFLAGS="-L${CURRENT_DIR}/cronet_build"

# https://github.com/pypa/wheel/issues/406
export _PYTHON_HOST_PLATFORM="macosx-11.0-arm64"
export ARCHFLAGS="-arch arm64"


function repair_wheel() {
  local python_version="$1"
  local wheel_version="$2"

  file $(which python${python_version})

#  arch -arm64 python${python_version} -m pip install delocate build
#  arch -arm64 python${python_version} -m build
#
#  delocate-wheel -w wheelhouse -v dist/python_cronet-${LIBCRONET_VERSION}-cp${wheel_version}-cp${wheel_version}-macosx_11_0_arm64.whl
}

repair_wheel "3.8" "38"
repair_wheel "3.9" "39"
repair_wheel "3.10" "310"
repair_wheel "3.11" "311"
repair_wheel "3.12" "312"
