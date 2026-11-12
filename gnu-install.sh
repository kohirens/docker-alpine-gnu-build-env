#!/bin/bash

set -e

# For details see:
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
getopt --test > /dev/null && true
if [ $? -ne 4 ]; then
    echo 'sorry, getopts --test` failed in this environment'
    exit 1
fi

LONG_OPTS=skip-verify,jobs:,tar-type:,sig-type:
OPTIONS=s,j:,t:

PARSED=$(getopt --options=${OPTIONS} --longoptions=${LONG_OPTS} --name "$0" -- "${@}") || exit 1
eval set -- "${PARSED}"

skip_sig_verify="0"
tar_type="gz"
sig_type="sig"
threads=""

while true; do
    case "${1}" in
        -j|--jobs)
            threads="${2}"
            shift 2
            ;;
        -s|--skip-verify)
            skip_sig_verify="1"
            shift
            ;;
        --sig-type)
            sig_type="${2}"
            shift 2
            ;;
        -t|--tar-type)
            tar_type="${2}"
            shift 2
            ;;
        --) shift; break;;
        *) echo "unknown option '${1}'"; exit 1;;
    esac
done

if [ "$#" -lt 1 ]; then
    echo "the app name is a required first argument"
    exit 1
fi

if [ "$#" -lt 2 ]; then
    echo "missing required second argument <app semantic version>, ex: 1.0.0 or 1.0"
    exit 1
fi

app_name="${1}"
soft_ver="${2}"

# download the source code
wget https://ftp.gnu.org/gnu/${app_name}/${app_name}-${soft_ver}.tar.${tar_type}

# download signature
wget https://ftp.gnu.org/gnu/${app_name}/${app_name}-${soft_ver}.tar.${tar_type}.${sig_type}

# check file against signature
if [ "${skip_sig_verify}" != "1" ]; then
    gpgv --keyring ./gnu-keyring.gpg ${app_name}-${soft_ver}.tar.${tar_type}.${sig_type} ${app_name}-${soft_ver}.tar.${tar_type}
fi

# extract the source
tar -xaf ${app_name}-${soft_ver}.tar.${tar_type}

# make a place to build
mkdir -p /tmp/build/${app_name}-${soft_ver}

cd /tmp/build/${app_name}-${soft_ver}

# configure the build
/tmp/src/${app_name}-${soft_ver}/configure

# build the code
if [ -n "${threads}" ]; then
    make -j"${threads}"
else
    make --jobs
fi

make install > /tmp/make-${app_name}-"${soft_ver}".log
