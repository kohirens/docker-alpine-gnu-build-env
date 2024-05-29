ARG ALPINE_VER
ARG GLIBC_VER

# Setup a build environment on Alpine that allows you to build the latest
# version of GNU software to-date.
# For details see https://www.gnu.org/software/software.html
FROM kohirens/alpine-glibc-build:${ALPINE_VER}-${GLIBC_VER} AS base

ARG ALPINE_VER
ARG GLIBC_VER

ENV LD_LIBRARY_PATH=""

WORKDIR /tmp/src

# gettext contains msgfmt
# texinfo contains makeinfo
# make check fails with error about ctype.h which is part of musl-dev
RUN apk --no-progress --purge --no-cache upgrade \
 && apk --no-progress --purge --no-cache add --upgrade \
    bash \
    binutils \
    file \
    gawk \
    gcc \
    git \
    gnupg \
    grep \
    linux-headers \
    make \
    perl \
    py3-pip \
    python3 \
    texinfo \
 && apk --no-progress --purge --no-cache upgrade \
 && rm -vrf /var/cache/apk/* \
 && sed -i -e 's|root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|g' /etc/passwd

COPY --chmod=+x start.sh /usr/local/bin
COPY --chmod=0777 gnu-install.sh .

ENTRYPOINT [ "start.sh" ]

RUN apk --no-progress --purge --no-cache add --upgrade --virtual .build.deps \
    g++

RUN apk --no-progress --purge --no-cache add --upgrade --virtual .build.deps.libc \
    libc-dev

# install m4 from source
FROM base AS m4

RUN ./gnu-install.sh "m4" "1.4.19" "xz" "sig" "1"

# install bison from source
FROM m4 AS bison

RUN ./gnu-install.sh "bison" "3.8.2" "xz" "sig" "1"

# install libssp from source
FROM bison AS libssp

RUN git clone https://github.com/intc/libssp-nonshared \
 && mkdir -p /tmp/build/libssp-nonshared \
 && cd libssp-nonshared \
 && ./configure \
 && make \
 && make install

# install gmp from source
FROM libssp AS gmp

ENV GMP_VER="6.3.0"

RUN wget https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VER}.tar.xz \
 && wget https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VER}.tar.xz.sig \
 && gpg --recv-keys 0x28C67298 \
 && gpg --verify gmp-${GMP_VER}.tar.xz.sig gmp-${GMP_VER}.tar.xz \
 && tar -xa -f gmp-${GMP_VER}.tar.xz \
 && mkdir -p /tmp/build/gmp-${GMP_VER} \
 && cd /tmp/build/gmp-${GMP_VER} \
 && ../../src/gmp-${GMP_VER}/configure \
 && make --jobs \
 && make install

# install mpfr from source
FROM gmp AS mpfr

ENV MPFR_VER="4.2.1"

RUN wget https://www.mpfr.org/mpfr-current/mpfr-${MPFR_VER}.tar.xz \
 && wget https://www.mpfr.org/mpfr-current/mpfr-${MPFR_VER}.tar.xz.asc \
# && gpg --verify mpfr-${MPFR_VER}.tar.xz.asc mpfr-${MPFR_VER}.tar.xz \
 && tar -xJf mpfr-${MPFR_VER}.tar.xz \
 && mkdir -p /tmp/build/mpfr-${MPFR_VER} \
 && cd /tmp/build/mpfr-${MPFR_VER} \
 && ../../src/mpfr-${MPFR_VER}/configure \
 && make --jobs \
 && make install

# install mpc from source
FROM mpfr AS mpc

ENV MPC_VER="1.3.1"

RUN wget https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz \
 && wget https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz.sig \
# && gpg --verify mpc-${MPC_VER}.tar.gz.sig mpc-${MPC_VER}.tar.gz \
 && tar -xaf mpc-${MPC_VER}.tar.gz \
 && mkdir -p /tmp/build/mpc-${MPC_VER} \
 && cd /tmp/build/mpc-${MPC_VER} \
 && ../../src/mpc-${MPC_VER}/configure \
 && make --jobs \
 && make install

# install gettext from source
FROM mpc AS gettext

ENV GETTEXT_VER="0.22.5"

RUN wget https://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VER}.tar.xz \
 && wget https://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VER}.tar.xz.sig \
# && gpg --verify gettext-${GETTEXT_VER}.tar.xz.sig gettext-${GETTEXT_VER}.tar.xz \
 && tar -xf gettext-${GETTEXT_VER}.tar.xz \
 && mkdir -p /tmp/build/gettext-${GETTEXT_VER} \
 && cd /tmp/build/gettext-${GETTEXT_VER} \
 && ../../src/gettext-${GETTEXT_VER}/configure \
 && make --jobs \
 && make install

# TODO: Get GCC from kohirens/docker-build-alpine-gcc when available.
FROM gettext AS cleanup

RUN rm -rf /tmp/*

FROM scratch as release

COPY --from=cleanup / /
