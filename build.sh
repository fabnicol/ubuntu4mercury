#!/bin/bash
docker build --squash --file Dockerfile --tag unbuntu:mercury .
docker save ubuntu:mercury | tar -9 cJvf ubuntu4mercury.tar.xz
echo b2sum: $(b2sum ubuntu4mercury.tar.xz) > SUMS
echo sha512sum: $(sha512sum ubuntu4mercury.tar.xz) >> SUMS

