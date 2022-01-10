#!/bin/bash

if docker build --squash --file Dockerfile --tag ubuntu:mercury .
then
    echo "Docker image was built as ubuntu:mercury"
else
    echo "Docker image creation failed."
fi
if docker save ubuntu:mercury -o ubuntu4mercury.tar
then
  if  xz -9 ubuntu4mercury.tar && rm ubuntu4mercury.tar \
                         && echo b2sum: $(b2sum ubuntu4mercury.tar.xz) > SUMS \
                         && echo sha512sum: $(sha512sum ubuntu4mercury.tar.xz) >> SUMS
  then
      echo "Compression performed."
  else
      echo "Could not compress the image tarball."
  fi
else
    echo "Docker could not save the image to tarball."
fi
