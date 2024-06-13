#!/usr/bin/bash

podman build \
    -f ./podman/Containerfile \
    -t localhost/ddeploy_build:latest \
    .
