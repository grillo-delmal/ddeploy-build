#!/usr/bin/bash

set -ex

source /opt/scripts/semver.sh

# Clean out folder
find /opt/out/ -mindepth 1 -maxdepth 1 -exec rm -r -- {} +

# Setup build srcs
cd /opt
mkdir -p src

rsync -azh /opt/orig/ddeploy/ /opt/src/ddeploy/


# Apply patches
if [ ! -z "./patches" ]; then
    pushd patches
    if [ ! -z "$(ls -A */ 2> /dev/null)" ]; then
        for d in */ ; do
            if [ ! -z "$(ls -A $d 2> /dev/null)" ]; then
                if [ ! -z "$(ls -A /opt/src/${d} 2> /dev/null)" ]; then
                    for p in ${d}*.patch; do
                        echo "patch /opt/patches/$p"
                        (cd /opt/src/${d}; patch -p1 < /opt/patches/$p)
                    done
                fi
            fi
        done
    fi
    popd
fi

dub add-local /opt/src/ddeploy/        "$(semver /opt/src/ddeploy/)"

# Build
pushd src
pushd ddeploy

export DFLAGS='-g --d-debug'
export DC='/usr/bin/ldc2'

dub build --config portable
./out/ddeploy new

popd
popd

# Get results

rsync -azh /opt/src/ddeploy/ /opt/out/ddeploy
