#!/bin/bash
docker build --squash --file Dockerfile --tag ubuntu:mercury .
docker save ubuntu:mercury | tar -cf - . | cat | xz -9 -c > ubuntu:mercury.tar.xz
echo b2sum: $(b2sum ubuntu4mercury.tar.xz) > SUMS
echo sha512sum: $(sha512sum ubuntu4mercury.tar.xz) >> SUMS

