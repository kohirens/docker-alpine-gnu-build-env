# Docker Alpine GNU Build Environment

A containerized environment for building GNU software on Alpine. Its recursive
because each new version of this environment uses the very artifacts it builds.

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/kohirens/docker-alpine-gnu-build-env/tree/main.svg?style=svg&circle-token=CCIPRJ_WVf9PiBPzDgTLfFapwTVLo_838a1d8f22302e05c2158026645f456ccc2d81ae)](https://dl.circleci.com/status-badge/redirect/gh/kohirens/docker-alpine-gnu-build-env/tree/main)

## GNU Build Environment on Alpine (Musl)

This build environment should allow most GNU sources to compile on Alpine. It
depends on the artifacts from the [Kohirens Alpine GNU Lib C] image, where
the artifact are located in the directory `/usr/glibc-<version>`. This creates
a recursive situation as that image also used this container to build itself.

You can see usage examples over at [Kohirens Alpine GNU Compiler Collection]
and [Kohirens Alpine GNU Lib C] projects. These projects also
provide artifacts that this projects uses, such as libstd++.so, libgcc_s.so.1,
etc. It's a real Uroborus, kinda deal, but GNU is kinda weird like that.

## Background

For a bit of history. Khalifah K. Shabazz first hacked together a system in a
Docker container using Alpine to build GNU Lib C. It was meant to produce the
Lib C artifacts, for running AWS Cli and NodeJS, and Java in an Alpine
container back in the day when options were not so abundant. After much trial
and error it evolved into 4 separate containers.

1. The [GNU build environment].
2. The [Docker Build Alpine GCC].
3. Another to [Build GLibC for Alpine].
4. ABuild container to streamline adding the package to APK.

## Usage

Use as a base.

```Dockerfile
FROM kohirens/docker-alpine-gnu-build-env:latest AS base

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
[GNU build environment]: https://github.com/kohirens/docker-alpine-gnu-build-env
[Docker Build Alpine GCC]: https://github.com/kohirens/docker-build-alpine-gcc
[Build GLibC for Alpine]: https://github.com/kohirens/docker-build-alpine-glibc
