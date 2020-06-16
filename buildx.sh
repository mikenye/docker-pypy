#!/usr/bin/env bash

set -x

TOTALTRIES=5
STARTTIME=$(date)

function build_image() {

    # build & push latest arch-specific
    local n=0
    until [ "$n" -ge "$TOTALTRIES" ]; do
        docker buildx build --platform "${BUILD_PLATFORM}" -t mikenye/pypy:latest${BUILD_ARCHLABEL} --progress plain --push . && break
        n=$((n+1))
        sleep 1
    done

    # Get latest arch-specific version
    docker pull mikenye/pypy:latest_${BUILD_ARCHLABEL}
    # Get version of python that pypy is built in:
    local PYTHONVER=$(docker --context=${BUILD_CONTEXT} run --rm -it --entrypoint /opt/pypy/bin/pypy3 mikenye/pypy:latest${BUILD_ARCHLABEL} --version | grep Python | cut -d " " -f 2)
    # Get version of pypy:
    local PYPYVER=$(docker --context=${BUILD_CONTEXT} run --rm -it --entrypoint /opt/pypy/bin/pypy3 mikenye/pypy:latest${BUILD_ARCHLABEL} --version | grep PyPy | cut -d " " -f 2)
    # Create version string
    local VERSION=pypy${PYTHONVER}-v${PYPYVER}${BUILD_ARCHLABEL}

    # build & push version-specific arch-specific
    local n=0
    until [ "$n" -ge "$TOTALTRIES" ]; do
        docker buildx build --platform "${BUILD_PLATFORM}" -t mikenye/pypy:${VERSION} --progress plain --push . && break
        n=$((n+1))
        sleep 1
    done
    
}

echo "========== Building & Pushing i386 =========="

BUILD_PLATFORM="linux/386"
BUILD_ARCHLABEL="_i386"
BUILD_CONTEXT="x86_64"
build_image | awk -W Interactive '{print "[i386] " $0}'

echo "========== Building & Pushing amd64 =========="

BUILD_PLATFORM="linux/amd64"
BUILD_ARCHLABEL="_amd64"
BUILD_CONTEXT="x86_64"
build_image | awk -W Interactive '{print "[amd64] " $0}'

echo "========== Building & Pushing armv6 =========="

BUILD_PLATFORM="linux/arm/v6"
BUILD_ARCHLABEL="_armv6"
BUILD_CONTEXT="arm32v7"
build_image | awk -W Interactive '{print "[armv6] " $0}'

echo "========== Building & Pushing armv7 =========="

BUILD_PLATFORM="linux/arm/v7"
BUILD_ARCHLABEL="_armv7"
BUILD_CONTEXT="arm32v7"
build_image | awk -W Interactive '{print "[armv7] " $0}'

echo "========== Building & Pushing arm64 =========="

BUILD_PLATFORM="linux/arm64"
BUILD_ARCHLABEL="_arm64"
BUILD_CONTEXT="arm64"
build_image | awk -W Interactive '{print "[arm64] " $0}'

echo "========== Building & Pushing multi-arch =========="

BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"
BUILD_ARCHLABEL=""
BUILD_CONTEXT="amd64"
build_image | awk -W Interactive '{print "[multiarch] " $0}'

echo "========== FINALLY FINISHED!!! =========="
echo Started: ${STARTTIME}
echo Finished: $(date)
echo ""