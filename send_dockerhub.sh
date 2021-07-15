#!/bin/bash

# Login if necessary
# docker login 

# Build and push
docker buildx build --push -t redbug26/cptc-docker:latest --platform linux/arm64,linux/amd64 .
