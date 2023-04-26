#!/bin/bash

# Login if necessary
# docker login 

# docker buildx create --use desktop-linux

# Build and push
docker buildx build --push -t redbug26/cptc-docker:latest --platform linux/amd64,linux/arm64 .
