ARG  ALPINE_VER=3.24
ARG      M4_VER=1.4.20
ARG   BISON_VER=3.8.2
ARG     GMP_VER=6.3.0
ARG    MPFR_VER=4.2.2
ARG     MPC_VER=1.4.1
ARG GETTEXT_VER=1.0
ARG DEJAGNU_VER=1.6.3
#ARG     TCL_VER=9.1.0
#ARG      TK_VER=9.1.0

# Setup a build environment on Alpine that allows you to build the latest
# version of GNU software to-date.
# For details see https://www.gnu.org/software/software.html
FROM alpine:${ALPINE_VER} AS base

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
 && sed -i -e 's|root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|g' /etc/passwd \
 && wget https://ftp.gnu.org/gnu/gnu-keyring.gpg

# TODO: Get GCC from kohirens/docker-build-alpine-gcc when available.
RUN apk --no-progress --purge --no-cache add --upgrade --virtual .build.deps.gpp \
    g++

RUN apk --no-progress --purge --no-cache add --upgrade --virtual .build.deps.libc \
    libc-dev

ENTRYPOINT [ "start.sh" ]

COPY --chmod=755 start.sh /usr/local/bin
COPY --chmod=755 gnu-*.sh /usr/local/bin

FROM base AS build

ARG M4_VER

RUN echo "$(nproc)" > number-of-procs.txt \
 && printf "number of processes allowed %s" "$(cat number-of-procs.txt)"

RUN gnu-install.sh -j "$(nproc)" -t "xz" "m4" "${M4_VER}"

ARG BISON_VER

RUN gnu-install.sh -j "$(nproc)" -t "xz" "bison" "${BISON_VER}"

ARG GMP_VER

RUN export CFLAGS="-O2 -std=gnu17" \
 && gnu-install.sh -j "$(nproc)" -t "xz" "gmp" "${GMP_VER}"

ARG MPFR_VER

RUN gnu-install.sh -j "$(nproc)" -t "xz" "mpfr" "${MPFR_VER}"

ARG MPC_VER

RUN gnu-install.sh -j "$(nproc)" -t "xz" "mpc" "${MPC_VER}"

ARG GETTEXT_VER

RUN gnu-install.sh -j "$(nproc)" -t "xz" -s "gettext" "${GETTEXT_VER}"

ARG DEJAGNU_VER

RUN gnu-install.sh -j "$(nproc)" -s "dejagnu" "${DEJAGNU_VER}"

#ARG TCL_VER

#RUN wget http://prdownloads.sourceforge.net/tcl/tcl${TCL_VER}-src.tar.gz \
# && gunzip < tcl${TCL_VER}-src.tar.gz | tar xvf - \
# && cd tcl${TCL_VER}/unix \
# && ./configure options \
# && make \
# && make install
#
#ARG TK_VER
#
#RUN wget http://prdownloads.sourceforge.net/tcl/tk${TK_VER}-src.tar.gz \
# && gunzip < tk${TCL_VER}-src.tar.gz | tar xvf - \
# && cd tk${TCL_VER}/unix \
# && configure options \
# && make \
# && make install

# Let us reduce bloat
FROM build AS cleanup

RUN rm -rf /tmp/*

FROM cleanup AS test

COPY --chmod=0644 test.cpp .
COPY --chmod=0655 test.sh .

FROM scratch AS release

COPY --from=cleanup / /

WORKDIR /tmp
