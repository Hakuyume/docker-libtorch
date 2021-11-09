ARG BASE
ARG CUDA
ARG CUDNN
FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-${BASE}

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends --yes \
    ca-certificates \
    cmake \
    curl \
    libjpeg-dev \
    libpng-dev \
    python3-dev \
    unzip

ARG CUDA
ARG TORCH
RUN CUDA_MAJOR_MINOR=$(echo ${CUDA} | perl -pe 's/(\d+)\.(\d+)\.\d+/$1$2/') \
    && curl -L https://download.pytorch.org/libtorch/cu${CUDA_MAJOR_MINOR}/libtorch-cxx11-abi-shared-with-deps-${TORCH}%2Bcu${CUDA_MAJOR_MINOR}.zip \
    -o libtorch.zip \
    && unzip libtorch.zip -d /usr/local/

ARG TORCHVISION
RUN curl -LO https://github.com/pytorch/vision/archive/refs/tags/v${TORCHVISION}.zip \
    && unzip v${TORCHVISION}.zip \
    && cmake -B vision-${TORCHVISION}/build/ \
    -DCMAKE_INSTALL_PREFIX=/usr/local/libtorch/ \
    -DPYTHON_EXECUTABLE=python3 \
    -DTorch_DIR=/usr/local/libtorch/share/cmake/Torch/ \
    vision-${TORCHVISION}/ \
    && make -C vision-${TORCHVISION}/build/ -j $(nproc) \
    && make -C vision-${TORCHVISION}/build/ install

FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-runtime-${BASE}

COPY --from=0 /usr/local/libtorch/ /usr/local/libtorch/
ENV LD_LIBRARY_PATH=/usr/local/libtorch/lib:${LD_LIBRARY_PATH}
