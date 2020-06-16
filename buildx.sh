#!/usr/bin/env bash

set -x

TOTALTRIES=5

# build & push i386
n=0
until [ "$n" -ge "$TOTALTRIES" ]; do
    docker buildx build --platform "linux/386" -t mikenye/pypy:latest_i386 --progress plain --push . && break
    n=$((n+1))
    sleep 1
done

# build & push amd64
n=0
until [ "$n" -ge "$TOTALTRIES" ]; do
    docker buildx build --platform "linux/amd64" -t mikenye/pypy:latest_amd64 --progress plain --push . && break
    n=$((n+1))
    sleep 1
done

# build & push armv6
n=0
until [ "$n" -ge "$TOTALTRIES" ]; do
    docker buildx build --platform "linux/arm/v6" -t mikenye/pypy:latest_armv6 --progress plain --push . && break
    n=$((n+1))
    sleep 1
done

# build & push armv7
n=0
until [ "$n" -ge "$TOTALTRIES" ]; do
    docker buildx build --platform "linux/arm/v7" -t mikenye/pypy:latest_armv7 --progress plain --push . && break
    n=$((n+1))
    sleep 1
done

# build & push arm64
n=0
until [ "$n" -ge "$TOTALTRIES" ]; do
    docker buildx build --platform "linux/arm64" -t mikenye/pypy:latest_arm64 --progress plain --push . && break
    n=$((n+1))
    sleep 1
done

# build & push multi-arch
n=0
until [ "$n" -ge "$TOTALTRIES" ]; do
    docker buildx build --platform "linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64" -t mikenye/pypy:latest --progress plain --push . && break
    n=$((n+1))
    sleep 1
done

# Get version
# docker pull mikenye/pypy:latest
# docker run --rm -it --entrypoint /opt/pypy/bin/pypy3 mikenye/pypy:latest --version | grep PyPy | cut -d " " -f 2
