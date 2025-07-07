# Debian slim builds: Compromise between small and reliable
FROM debian:trixie-20250630-slim

# Install build dependencies
# TODO: Verify dependencies (kmod might not be needed)
RUN apt-get update && \
  apt-get install -y \
    bc \
    bindgen \
    binutils \
    bison \
    build-essential \
    byacc \
    bzip2 \
    cbindgen \
    clang \
    cmake \
    cpio \
    curl \
    devscripts \
    dosfstools \
    elfutils \
    fakeroot \
    file \
    flex \
    fontconfig \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-noto-core \
    git \
    glslang-tools \
    gperf \
    jq \
    kmod \
    libbluetooth-dev \
    libbz2-dev \
    libcap-dev \
    libclc-19-dev \
    libcups2-dev \
    libcurl4-gnutls-dev \
    libdbus-1-dev \
    libdrm-dev \
    libelf-dev \
    libevdev-dev \
    libexpat1-dev \
    libffi-dev \
    libfontconfig1-dev \
    libgbm-dev \
    libglvnd-core-dev \
    libinput-dev \
    libjpeg-dev \
    libkrb5-dev \
    libllvmspirvlib-19-dev \ 
    libnspr4 \
    libnspr4-dev \
    libnss3 \
    libnss3-dev \
    libpam0g-dev \
    libpci-dev \
    libpciaccess-dev \
    libpolly-19-dev \
    libsctp-dev \
    libsqlite3-dev \
    libssl-dev \
    libsystemd-dev \
    libudev-dev \
    libunwind-dev \
    libva-dev \
    libvulkan-dev \
    libxkbcommon-dev \
    libxshmfence-dev \
    llvm-19-dev \
    llvm-spirv-19 \
    lsb-release \
    mesa-common-dev \
    meson \
    ninja-build \
    p7zip \
    patch \
    perl \
    pkg-config \
    python3-mako \
    python3-pip \
    rdfind \
    rpm \
    rsync \
    ruby \
    sqlite3 \
    sudo \
    systemd-ukify \
    util-linux \
    uuid-dev \
    wget \
    xz-utils \
    zip \
    zlib1g-dev \
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
