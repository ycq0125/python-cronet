#!/bin/bash


echo "Building with Chromium version: ${CHROMIUM_VERSION}"
echo "Using libcronet version: ${LIBCRONET_VERSION}"


# 获取当前工作目录的路径
CURRENT_DIR="$(pwd)"

# 设置脚本遇到错误即停止执行
set -e

# 在当前工作目录下创建一个新目录 'out'，并清空其中的内容
mkdir -p out
rm -rf out/*
cd out

# 克隆 depot_tools 仓库，将其路径加入到环境变量中
git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="${CURRENT_DIR}/out/depot_tools:$PATH"
# 克隆 Chromium 源码仓库的指定分支
git clone -b ${CHROMIUM_VERSION} --depth=2 https://chromium.googlesource.com/chromium/src

# 进入到源码目录，应用 patch
cd src
git apply ../../libcronet/proxy_support_*.patch
cd ..
echo 'solutions = [
      {
        "name": "src",
        "url": "https://chromium.googlesource.com/chromium/src.git",
        "managed": False,
        "custom_deps": {},
        "custom_vars": {},
      },
]' > .gclient

# 同步源码，跳过历史记录和钩子
gclient sync --no-history --nohooks

# 安装 psutil 依赖
pip install psutil

# 运行 gclient 钩子
gclient runhooks

cd src/components/cronet

gn gen out/Cronet/ --args='target_os="mac" is_debug=false is_component_build=false target_cpu="arm64"'

ninja -C out/Cronet cronet_package

cp -r out/Cronet/cronet/ ${CURRENT_DIR}/cronet_build
ls ${CURRENT_DIR}/cronet_build
cd ${CURRENT_DIR}
rm -rf out
