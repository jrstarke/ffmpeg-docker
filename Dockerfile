FROM debian:bullseye as builder

ARG SOURCE_DIR="/tmp/source"
ARG BUILD_DIR="/tmp/build"
ARG BIN_DIR="${HOME}/bin"

ARG FFMPEG_VERSION="4.4.1"
ARG NASM_VERSION="2.15.05"
ARG X265_VER="2.9"

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install \
      autoconf \
      automake \
      build-essential \
      cmake \
      curl \
      git-core \
      libaom-dev \
      libass-dev \
      libdav1d-dev \
      libdrm-dev \
      libfreetype6-dev \
      libgnutls28-dev \
      libmp3lame-dev \
      libnuma-dev \
      libtool \
      libunistring-dev \
      libvorbis-dev \
      meson \
      ninja-build \
      pkg-config \
      texinfo \
      yasm \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${SOURCE_DIR} ${BUILD_DIR} ${BIN_DIR}

# NASM
RUN curl -o ${SOURCE_DIR}/nasm-${NASM_VERSION}.tar.bz2 -L https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.bz2 && \
    tar xf ${SOURCE_DIR}/nasm-${NASM_VERSION}.tar.bz2 -C ${BUILD_DIR} && \
    cd ${BUILD_DIR}/nasm-${NASM_VERSION} && \
    ./autogen.sh && \
    PATH="$BIN_DIR:$PATH" ./configure --prefix="${BUILD_DIR}" --bindir="${BIN_DIR}" && \
    make && \
    make install

# x264
#RUN curl -o ${SOURCE_DIR}/x264-stable.tar.bz2 -L https://code.videolan.org/videolan/x264/-/archive/stable/x264-stable.tar.bz2 && \
#    tar xf ${SOURCE_DIR}/x264-stable.tar.bz2 -C ${BUILD_DIR} && \
#    cd ${BUILD_DIR}/x264-stable && \
#    PATH="$BIN_DIR:$PATH" PKG_CONFIG_PATH="${BUILD_DIR}/lib/pkgconfig" ./configure --prefix="${BUILD_DIR}" --bindir="$BIN_DIR" --enable-static --enable-pic && \
#    PATH="$BIN_DIR:$PATH" make && \
#    make install

# x265
#RUN curl -o ${SOURCE_DIR}/x265_${X265_VER}.tar.gz -L https://bitbucket.org/multicoreware/x265_git/downloads/x265_${X265_VER}.tar.gz && \
#    tar xf ${SOURCE_DIR}/x265_${X265_VER}.tar.gz -C ${BUILD_DIR} && \
#    cd ${BUILD_DIR}/x265_${X265_VER}/build/linux && \
#    PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off ../../source && \
#    PATH="$HOME/bin:$PATH" make && \
#    make install

# rkmpp \
RUN curl -o ${SOURCE_DIR}/develop.tar.gz -L https://github.com/rockchip-linux/mpp/archive/refs/heads/develop.tar.gz && \
    tar xf ${SOURCE_DIR}/develop.tar.gz -C ${BUILD_DIR} && \
    cd ${BUILD_DIR}/mpp-develop/build/linux/aarch64 && \
    PATH="$HOME/bin:$PATH" ./make-Makefiles.bash && \
    PATH="$HOME/bin:$PATH" make && \
    make install

# Fetch and Install FFMPEG
RUN curl -o ${SOURCE_DIR}/ffmpeg-${FFMPEG_VERSION}.tar.bz2 -L http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
    tar xf ${SOURCE_DIR}/ffmpeg-${FFMPEG_VERSION}.tar.bz2 -C ${BUILD_DIR} && \
    cd ${BUILD_DIR}/ffmpeg-${FFMPEG_VERSION} && \
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
#      --enable-libfdk-aac \
#      --enable-libfreetype \
      --enable-libdrm \
      --enable-libmp3lame \
#      --enable-libopus \
#      --enable-libsvtav1 \
#      --enable-libdav1d \
#      --enable-libvorbis \
#      --enable-libvpx \
#      --enable-libx264 \
#      --enable-libx265 \
#      --enable-nonfree \
      --enable-rkmpp \
      --enable-version3 \
      --enable-decoder=h264_rkmpp \
      --enable-decoder=hevc_rkmpp \
      --enable-decoder=vp9_rkmpp \
    && \
    PATH="$BIN_DIR:$PATH" make && \
    make install && \
    hash -r
