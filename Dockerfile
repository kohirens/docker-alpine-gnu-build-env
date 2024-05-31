ARG ALPINE_VER

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
 && sed -i -e 's|root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|g' /etc/passwd

ENTRYPOINT [ "start.sh" ]

# TODO: Get GCC from kohirens/docker-build-alpine-gcc when available.
RUN apk --no-progress --purge --no-cache add --upgrade --virtual .build.deps.gpp \
    g++

RUN apk --no-progress --purge --no-cache add --upgrade --virtual .build.deps.libc \
    libc-dev

COPY --chmod=+x start.sh /usr/local/bin
COPY --chmod=0777 gnu-*.sh .

# install m4 from source
FROM base AS m4

RUN ./gnu-install.sh -t "xz" -s "m4" "1.4.19"

# install bison from source
FROM m4 AS bison

RUN ./gnu-install.sh -t "xz" -s "bison" "3.8.2"

# install gmp from source
FROM bison AS gmp

RUN gpg --recv-keys 0x28C67298 \
 && ./gnu-install.sh -t "xz" "gmp" "6.3.0"

# install mpfr from source
FROM gmp AS mpfr

RUN ./gnu-install.sh -t "xz" -s "mpfr" "4.2.1"

# install mpc from source
FROM mpfr AS mpc

RUN ./gnu-install.sh -s "mpc" "1.3.1"

# install gettext from source
FROM mpc AS gettext

RUN ./gnu-install.sh -t "xz" -s "gettext" "0.22.5"

# Let us reduce bloat
FROM gettext AS cleanup

RUN rm -rf /tmp/*

FROM scratch as release

COPY --from=cleanup / /

WORKDIR /tmp
