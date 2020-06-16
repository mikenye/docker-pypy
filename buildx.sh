#!/usr/bin/env bash

set -x

TOTALTRIES=5
STARTTIME=$(date)

function build_image() {
    
    n=0
    until [ "$n" -ge "$TOTALTRIES" ]; do
        docker buildx build --platform "${BUILD_PLATFORM}" -t mikenye/pypy:${VERSION} --progress plain --push . && break
        n=$((n+1))
        sleep 1
    done
}

function check_version_vars() {

    if [ "${PYTHONVER}" == "" ]; then
        echo "ERROR: PYTHONVER is empty"
        exit 1
    fi
    if [ "${PYPYVER}" == "" ]; then
        echo "ERROR: PYPYVER is empty"
        exit 1
    fi

}

function build_process() {

    # build & push "latest"
    VERSION="latest${BUILD_ARCHLABEL}"
    build_image

    # Get versions
    docker pull mikenye/pypy:${VERSION}
    # Get version of python that pypy is built on (x.x.x):
    PYTHONVER=$(docker --context=${BUILD_CONTEXT} run --rm -it --entrypoint /opt/pypy/bin/pypy3 mikenye/pypy:${VERSION} --version | grep Python | cut -d " " -f 2)
    # Get version of pypy (x.x.x):
    PYPYVER=$(docker --context=${BUILD_CONTEXT} run --rm -it --entrypoint /opt/pypy/bin/pypy3 mikenye/pypy:${VERSION} --version | grep PyPy | cut -d " " -f 2)
    # Make sure we have version data returned
    check_version_vars

    # build & push "pypyX.X.X-vY.Y.Y"
    # Create version string
    VERSION=pypy${PYTHONVER}-v${PYPYVER}${BUILD_ARCHLABEL}
    # build & push version-specific arch-specific
    build_image

    # build & push "pypyX.X.X"
    # Create version string
    VERSION=pypy${PYTHONVER}${BUILD_ARCHLABEL}
    # build & push version-specific arch-specific
    build_image

    # build & push "pypyX.X"
    # Get version of python that pypy is built on (x.x):
    PYTHONVER=$(docker --context=${BUILD_CONTEXT} run --rm -it --entrypoint /opt/pypy/bin/pypy3 mikenye/pypy:latest${BUILD_ARCHLABEL} --version | grep Python | cut -d " " -f 2 | cut -d "." -f 1,2)
    # Make sure we have version data returned
    check_version_vars
    # Create version string
    VERSION=pypy${PYTHONVER}${BUILD_ARCHLABEL}
    # build & push version-specific arch-specific
    build_image

    # build & push "pypyX"
    # Get version of python that pypy is built on (x):
    PYTHONVER=$(docker --context=${BUILD_CONTEXT} run --rm -it --entrypoint /opt/pypy/bin/pypy3 mikenye/pypy:latest${BUILD_ARCHLABEL} --version | grep Python | cut -d " " -f 2 | cut -d "." -f 1)
    # Make sure we have version data returned
    check_version_vars
    # Create version string
    VERSION=pypy${PYTHONVER}${BUILD_ARCHLABEL}
    # build & push version-specific arch-specific
    build_image

}

echo "========== Building & Pushing i386 =========="
BUILD_PLATFORM="linux/386"
BUILD_ARCHLABEL="_i386"
BUILD_CONTEXT="x86_64"
build_process 2>&1 | awk '{print "[i386] " $0}'

echo "========== Building & Pushing amd64 =========="
BUILD_PLATFORM="linux/amd64"
BUILD_ARCHLABEL="_amd64"
BUILD_CONTEXT="x86_64"
build_process 2>&1 | awk '{print "[amd64] " $0}'

echo "========== Building & Pushing armv7 =========="
BUILD_PLATFORM="linux/arm/v7"
BUILD_ARCHLABEL="_armv7"
BUILD_CONTEXT="arm32v7"
build_process 2>&1 | awk '{print "[armv7] " $0}'

echo "========== Building & Pushing arm64 =========="
BUILD_PLATFORM="linux/arm64"
BUILD_ARCHLABEL="_arm64"
BUILD_CONTEXT="arm64"
build_process 2>&1 | awk '{print "[arm64] " $0}'

echo "========== Building & Pushing multi-arch =========="
BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"
BUILD_ARCHLABEL=""
BUILD_CONTEXT="amd64"
build_process 2>&1 | awk '{print "[multiarch] " $0}'

echo "========== FINALLY FINISHED!!! =========="
echo Started: ${STARTTIME}
echo Finished: $(date)
echo ""