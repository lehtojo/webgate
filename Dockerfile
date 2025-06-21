# Debian slim builds: Compromise between small and reliable
FROM debian:trixie-slim

# Install build dependencies
# TODO: Verify dependencies (kmod might not be needed)
RUN apt-get update && \
  apt-get install -y \
    build-essential \
    byacc \
    clang \
    cmake \
    cpio \
    dosfstools \
    flex \
    git \
    glslang-tools \
    jq \
    kmod \
    libdrm-dev \
    libelf-dev \
    libexpat1-dev \
    libglvnd-core-dev \
    libpciaccess-dev \
    libudev-dev \
    libunwind-dev \
    meson \
    ninja-build \
    pkg-config \
    python3-mako \
    python3-pip \
    llvm-spirv-19 \
    systemd-ukify \
    util-linux \
    zstd && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /
ENTRYPOINT [ "/workspace/scripts/docker.sh" ]
