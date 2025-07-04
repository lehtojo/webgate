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
    wget \
    zstd && \
  rm -rf /var/lib/apt/lists/*

# Setup Rust toolchain
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.88.0

RUN wget -q -O rustup.sh https://sh.rustup.rs && \
    chmod +x rustup.sh && \
    ./rustup.sh -y --no-modify-path --profile minimal --default-toolchain "$RUST_VERSION" && \
    rm rustup.sh && \
    architecture=$(uname -m) && \
    case "$architecture" in \
        x86_64)  target="x86_64-unknown-linux-musl" ;; \
        aarch64) target="aarch64-unknown-linux-musl" ;; \
        armv7l)  target="armv7-unknown-linux-musleabihf" ;; \
        *)       echo "Unsupported architecture: $architecture" && exit 1 ;; \
    esac && \
    rustup target add "$target" && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME

WORKDIR /
ENTRYPOINT [ "/workspace/scripts/docker.sh" ]
