# Debian slim builds: Compromise between small and reliable
FROM debian:trixie-slim

# Install build dependencies
# TODO: Verify dependencies (kmod might not be needed)
RUN apt-get update && \
  apt-get install -y \
    bc \
    bison \
    build-essential \
    byacc \
    clang \
    cmake \
    cpio \
    dosfstools \
    fontconfig \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-noto-core \
    flex \
    git \
    glslang-tools \
    jq \
    kmod \
    libdrm-dev \
    libelf-dev \
    libexpat1-dev \
    libglvnd-core-dev \
    libnspr4 \
    libnss3 \
    libssl-dev \
    libpciaccess-dev \
    libpolly-19-dev \
    libudev-dev \
    libunwind-dev \
    llvm-19-dev \
    llvm-spirv-19 \
    meson \
    ninja-build \
    pkg-config \
    python3-mako \
    python3-pip \
    rdfind \
    rsync \
    systemd-ukify \
    util-linux \
    zstd && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /
ENTRYPOINT [ "/workspace/scripts/docker.sh" ]
