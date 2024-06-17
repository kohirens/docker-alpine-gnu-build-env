# Docker <no value>

The source for `alpine-gnu-build-env` image.

## GNU Build Environment on Alpine (Musl)

This build environment should allow most GNU sources to compile on Alpine. It
depends on the artifact from the [Kohirens Alpine GNU Lib C] image, where
the artifact are located in the directory `/usr/glibc-<version>`. This creates
a chicken-egg situation as that image also used this GCC to build itself (FYI
the GNU Lib C came first).

You can see usage examples over at [Kohirens Alpine GNU Compiler Collection]
and [Kohirens Alpine GNU Lib C] projects. These projects also
provide artifacts that this projects uses, such as libstd++.so, libgcc_s.so.1,
etc. It's a real Uroborus, kinda deal, but GNU is kinda wierd like that.

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/kohirens/docker-alpine-gnu-build-env/tree/main.svg?style=svg&circle-token=CCIPRJ_WVf9PiBPzDgTLfFapwTVLo_838a1d8f22302e05c2158026645f456ccc2d81ae)](https://dl.circleci.com/status-badge/redirect/gh/kohirens/docker-alpine-gnu-build-env/tree/main)

## Usage

To pull the latest released image:

```shell
docker pull kohirens/docker-alpine-gnu-build-env
```

Or to use as a base of another image

```Docker
FROM kohirens/docker-alpine-gnu-build-env AS base

RUN ...
```

For Docker image tags see [kohirens/docker-alpine-gnu-build-env]

## Resources

* [Binutils Porting Guide To A New Target/Processor Architecture]
* [How do I parse command line arguments in Bash]

---

[kohirens/docker-alpine-gnu-build-env]: https://hub.docker.com/repository/docker/kohirens/docker-alpine-gnu-build-env
[Kohirens Alpine GNU Lib C]: https://github.com/kohirens/docker-build-alpine-glibc
[Binutils Porting Guide To A New Target/Processor Architecture]: https://sourceware.org/binutils/binutils-porting-guide.txt
[How do I parse command line arguments in Bash]: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
[Kohirens Alpine GNU Compiler Collection]: https://github.com/kohirens/docker-build-alpine-gcc
