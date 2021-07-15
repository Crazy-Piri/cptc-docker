#!/bin/bash

set -euo pipefail

export GITHUB_REPO=Crazy-Piri/cptc-docker
export VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/${GITHUB_REPO}/releases/latest | cut -d '/' -f 8)
export CLEAN_VERSION=${VERSION#*v}
export DOCKER_REPO=redbug26/cptc-docker

docker manifest inspect ${DOCKER_REPO}:${VERSION} > /dev/null && echo "Version ${VERSION} is already exists" && exit 0

for ARCH_TYPE in amd64 arm64 
do
    if [ "$ARCH_TYPE" == "amd64" ];then
        export TARGET=amd64
        export QEMU_ARCH=x86_64
        export ARCH=amd64
    elif [ "$ARCH_TYPE" == "arm64" ]; then
        export TARGET=arm64v8
        export QEMU_ARCH=aarch64
        export ARCH=arm64
    else
        echo "unsupported architecture type"
        return 1
    fi

done

docker manifest create --amend \
    ${DOCKER_REPO}:${VERSION} \
    ${DOCKER_REPO}:${VERSION}-amd64 \
    ${DOCKER_REPO}:${VERSION}-arm64

for OS_ARCH in linux_amd64 linux_arm64
do
    ARCH=${OS_ARCH#*_}
    OS=${OS_ARCH%%_*}

    docker manifest annotate \
        ${DOCKER_REPO}:${VERSION} \
        ${DOCKER_REPO}:${VERSION}-${ARCH} \
        --os ${OS} --arch ${ARCH}

done

docker manifest annotate \
    ${DOCKER_REPO}:${VERSION} \
    ${DOCKER_REPO}:${VERSION}-arm \
    --os linux --arch arm --variant v7

docker manifest push ${DOCKER_REPO}:${VERSION}
