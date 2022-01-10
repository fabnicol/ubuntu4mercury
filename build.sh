# Copyright (C) 2022 Fabrice Nicol

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

#!/bin/bash

if [ $# = 1 ]
then
    echo "Using git source revision $1"
    sed "s/06f81f1cf0d339a/$1/g" Dockerfile.in > Dockerfile2
    sed -i "s/-@/-2022-01-09/g" Dockerfile2
    DOCKERFILE="Dockerfile2"
    REVISION="$1"
    DATE="2022-01-09"
elif [ $# = 2 ] && [ "$2" != "06f81f1cf0d339a" ]
then
    echo "Using ROTD dated $1 and git source revision $2"
    sed "s/REVISION/$2/g" Dockerfile.in > Dockerfile2
    sed -i "s/-@/-$1/g" Dockerfile2
    DOCKERFILE="Dockerfile2"
    REVISION="$2"
    DATE="$1"
else
    DOCKERFILE="Dockerfile"
    REVISION="06f81f1cf0d339a"
    DATE="2022-01-09"
fi

if ! docker version -f '{{.Client.Experimental}}' || ! docker version -f '{{.Server.Experimental}}'
then
    echo $'{\n  "experimental": true\n}' | sudo tee /etc/docker/daemon.json
    mkdir -p ~/.docker
    echo $'{\n  "experimental": "enabled"\n}' | sudo tee ~/.docker/config.json
    if ! service docker restart
    then
        # for those with open-rc
        rc-service docker restart
    fi
    if ! docker version -f '{{.Client.Experimental}}' || ! docker version -f '{{.Server.Experimental}}'
    then
        echo "Could not use experimental version of Docker. Remove --squash from script and run it again."
        echo "(Also remove the present test!)"
        exit 1
    fi
fi

if docker build --squash --file ${DOCKERFILE} --tag ubuntu:mercury${REVISION} .
then
    echo "Docker image was built as ubuntu:mercury${REVISION}"
else
    echo "Docker image creation failed."
    exit 2
fi
if docker save ubuntu:mercury${REVISION} -o ubuntu4mercury.tar
then
  if  xz -9 -k -f ubuntu4mercury.tar && gzip -v -f ubuntu4mercury.tar \
                         && echo "ROTD DATE: ${DATE}" \
                         && echo "GIT SOURCE REVISION: ${REVISION}" \
                         && echo b2sum: $(b2sum ubuntu4mercury.tar.xz) >> SUMS \
                         && echo b2sum: $(b2sum ubuntu4mercury.tar.gz) >> SUMS \
                         && echo sha512sum: $(sha512sum ubuntu4mercury.tar.xz) >> SUMS \
                         && echo sha512sum: $(sha512sum ubuntu4mercury.tar.gz) >> SUMS
  then
      echo "Compression performed."
  else
      echo "Could not compress the image tarball."
      exit 3
  fi
else
    echo "Docker could not save the image to tarball."
    exit 4
fi
