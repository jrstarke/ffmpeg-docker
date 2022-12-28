FROM debian:bullseye as builder

ARG SOURCE_DIR="/tmp/source"
ARG BUILD_DIR="/tmp/build"
ARG BIN_DIR="${HOME}/bin"

ARG FFMPEG_VERSION="4.4.1"
ARG NASM_VERSION="2.15.05"

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install \
      autoconf \
      automake \
      build-essential \
      cmake \
      git-core \
      libass-dev \
      libfreetype6-dev \
      libgnutls28-dev \
      libmp3lame-dev \
      libtool \
      libvorbis-dev \
      meson \
      ninja-build \
      pkg-config \
      texinfo \
      wget \
      yasm \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${SOURCE_DIR} ${BUILD_DIR} ${BIN_DIR}

# Fetch and Install NASM
RUN curl -o ${SOURCE_DIR}/nasm.tar.bz2 -L https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.bz2 && \
    tar xf ${SOURCE_DIR}/nasm.tar.bz2 -C ${BUILD_DIR} && \
    cd ${BUILD_DIR}/nasm-${NASM_VERSION} && \
    ./autogen.sh && \
    PATH="$BIN_DIR:$PATH" ./configure --prefix="${BUILD_DIR}" --bindir="${BIN_DIR}" && \
    make && \
    make install

# Fetch and Install x264
RUN curl -o ${SOURCE_DIR}/last_x264.tar.bz2 -L http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 && \
    tar xf ${SOURCE_DIR}/x264.tar.bz -C ${BUILD_DIR} && \
    cd ${BUILD_DIR}/x264 && \
    PATH="$BIN_DIR:$PATH" PKG_CONFIG_PATH="${BUILD_DIR}/lib/pkgconfig" ./configure --prefix="${BUILD_DIR}" --bindir="$BIN_DIR" --enable-static --enable-pic && \
    PATH="$BIN_DIR:$PATH" make && \
    make install

# Fetch and Install FFMPEG
RUN curl -o ${SOURCE_DIR}/ffmpeg.tar.bz2 -L http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
    tar xf ${SOURCE_DIR}/ffmpeg.tar.bz2 -C ${BUILD_DIR} && \
    cd ${BUILD_DIR}/ffmpeg* && \
    PATH="$BIN_DIR:$PATH" PKG_CONFIG_PATH="${BUILD_DIR}/lib/pkgconfig" ./configure \
      --prefix="${BUILD_DIR}" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I${BUILD_DIR}/include" \
      --extra-ldflags="-L${BUILD_DIR}/lib" \
      --extra-libs="-lpthread -lm" \
      --ld="g++" \
      --bindir="$BIN_DIR" \
      --enable-gpl \
      --enable-gnutls \
      --enable-libaom \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libsvtav1 \
      --enable-libdav1d \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-nonfree && \
    PATH="$BIN_DIR:$PATH" make && \
    make install && \
    hash -r
