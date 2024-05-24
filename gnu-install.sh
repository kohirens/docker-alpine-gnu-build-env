#!/bin/sh

set -e

tar_type="gz"
sig_type="sig"
skip_sig_verify="0"

app_name="${1}"
soft_ver="${2}"

if [ -n "${3}" ]; then
    tar_type="${3}"
fi

if [ -n "${4}" ]; then
    sig_type="${4}"
fi

if [ -n "${5}" ]; then
    skip_sig_verify="${5}"
fi

# download the source code
wget https://ftp.gnu.org/gnu/${app_name}/${app_name}-${soft_ver}.tar.${tar_type}

# download signature
wget https://ftp.gnu.org/gnu/${app_name}/${app_name}-${soft_ver}.tar.${tar_type}.${sig_type}

# check file against signature
if [ "${skip_sig_verify}" != "1" ]; then
    gpg --verify ${app_name}-${soft_ver}.tar.${tar_type}.${sig_type} ${app_name}-${soft_ver}.tar.${tar_type}
fi

# extract the source
tar -xaf ${app_name}-${soft_ver}.tar.${tar_type}

# make a place to build
mkdir -p /tmp/build/${app_name}-${soft_ver}

cd /tmp/build/${app_name}-${soft_ver}

# configure the build
/tmp/src/${app_name}-${soft_ver}/configure

# build the code
make --jobs

make install > /tmp/make-${app_name}-"${soft_ver}".log
