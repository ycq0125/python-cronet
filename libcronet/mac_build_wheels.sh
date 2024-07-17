#!/bin/bash


echo "Building with Chromium version: ${CHROMIUM_VERSION}"
echo "Using libcronet version: ${LIBCRONET_VERSION}"


# 获取当前工作目录的路径
CURRENT_DIR="$(pwd)"

# 设置脚本遇到错误即停止执行
set -e

export CPPFLAGS="-I${CURRENT_DIR}/cronet_build/include"
export LDFLAGS="-L${CURRENT_DIR}/cronet_build"

# https://github.com/pypa/wheel/issues/406
export _PYTHON_HOST_PLATFORM="macosx-11.0-arm64"
export ARCHFLAGS="-arch arm64"

echo "sudo ls ls /usr"
sudo ls ls /usr
#echo "ls /usr/local"
#ls /usr/local
#echo "ls /usr/local/lib"
#ls /usr/lib

## Fix directory structure
#sudo mkdir -p /usr/local/include && \
#    sudo chown -R $(whoami) /usr/local/include
#sudo mkdir -p /usr/local/lib && \
#    sudo chown -R $(whoami) /usr/local/lib
#sudo mkdir -p /usr/local/share && \
#    sudo chown -R $(whoami) /usr/local/share


function repair_wheel() {
  local python_version="$1"
  local wheel_version="$2"

  file $(which python)

  arch -arm64 python -m pip install delocate build
  arch -arm64 python -m build

  ls ${CURRENT_DIR}/cronet_build
  echo "cp lib"
#  cp ${CURRENT_DIR}/cronet_build/libcronet*dylib /usr/local/lib/

#  ls /usr/local/lib
  delocate-wheel -w wheelhouse -v dist/python_cronet-${LIBCRONET_VERSION}-cp${wheel_version}-cp${wheel_version}-macosx_11_0_arm64.whl
}

# 将 matrix.python-version 传递到脚本中，并生成 wheel
PYTHON_VERSION=$1

# 映射 Python 版本到 wheel 版本
case $PYTHON_VERSION in
  "3.8") WHEEL_VERSION="38" ;;
  "3.9") WHEEL_VERSION="39" ;;
  "3.10") WHEEL_VERSION="310" ;;
  "3.11") WHEEL_VERSION="311" ;;
  "3.12") WHEEL_VERSION="312" ;;
  *) echo "Unsupported Python version: $PYTHON_VERSION" ; exit 1 ;;
esac

repair_wheel "${PYTHON_VERSION}" "${WHEEL_VERSION}"
