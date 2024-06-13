#!/usr/bin/bash

set -e

mkdir -p $(pwd)/build_out
mkdir -p $(pwd)/patches

if [ "$EUID" -ne 0 ]; then
    ./build_images.sh
    podman unshare chown $UID:$UID -R $(pwd)/build_out
fi

podman run -ti --rm \
    -v $(pwd)/build_out:/opt/out/:Z \
    -v $(pwd)/patches:/opt/patches/:ro,Z \
    -v $(pwd)/scripts:/opt/scripts/:ro,Z \
    -v $(pwd)/.git:/opt/.git/:ro,Z \
    -v $(pwd)/src/ddeploy:/opt/orig/ddeploy/:ro,Z \
    ddeploy_build:latest \
    /opt/scripts/build.sh

if [ "$EUID" -ne 0 ]; then
    podman unshare chown 0:0 -R $(pwd)/build_out
fi
