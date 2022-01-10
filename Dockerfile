# Copyright (C) 2022  Fabrice Nicol
#
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

FROM ubuntu:21.10
# for apt to be noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt update && apt upgrade -y
# build essentials
RUN apt install -y wget git xz-utils build-essential flex bison libtool texinfo info \
                   libgif-dev libgnutls28-dev mailutils pkg-config \
                   libncurses-dev libxaw7-dev libjpeg-dev libpng-dev libtiff-dev
# download auxiliary ROTD build, to bootstrap image building
RUN wget https://github.com/fabnicol/ubuntu4mercury/releases/download/v1.1/rotd.tar.xz
RUN tar xJvf rotd.tar.xz && rm rotd.tar.xz 
RUN echo PATH='/usr/local/mercury-rotd-2022-01-09/bin:$PATH' >> /etc/profile
RUN wget https://github.com/Mercury-Language/mercury-srcdist/archive/refs/tags/rotd-2022-01-09.tar.gz 
RUN tar xzvf rotd-2022-01-09.tar.gz
RUN echo 'source /etc/profile' >> /root/.bashrc
# rebuild the same ROTD within the docker image for security-minded users
# using ENV as sourcing /etc/profile will do only when the image is created, not while building it.
ENV PATH=/usr/local/mercury-rotd-2022-01-09/bin:$PATH
RUN cd mercury-srcdist-rotd-2022-01-09 && /bin/bash configure && make install PARALLEL=-j4 
RUN rm -rf /mercury-srcdist-rotd-2022-01-09
# now with this secured ROTD build the Mercury git source
RUN git clone --shallow-since=2022-01-08 \
              -b master https://github.com/Mercury-Language/mercury.git \
              && cd /mercury && git reset --hard 06f81f1cf0d339a
# synchronize the ROTD and git source dates otherwise it may not build
RUN cd /mercury \
   && /bin/bash prepare.sh && /bin/bash configure --disable-most-grades \
   && make install PARALLEL=-j4 
RUN echo PATH='$PATH:/usr/local/mercury-DEV/bin' >> /etc/profile
RUN rm -rf /mercury
# do the same for emacs, with Mercury support for etags (source code tagging)
RUN git clone --depth=1 -b master --single-branch git://git.sv.gnu.org/emacs.git
RUN cd emacs && /bin/bash autogen.sh \
   && /bin/bash configure --prefix=/usr/local/emacs-DEV \
   && make install -j4 
# companion tools, you may add tools to his list below as you wish:   
RUN apt install -y vim nano gdb
# adjust paths and cleanup
RUN echo PATH='$PATH:/usr/local/emacs-DEV/bin' >> /etc/profile
RUN echo MANPATH='$MANPATH:/usr/local/mercury-rotd-2022-01-09/man' >> /etc/profile
RUN echo INFOPATH='$INFOPATH:/usr/local/mercury-rotd-2022-01-09/info' >> /etc/profile
RUN echo "(add-to-list 'load-path \n\
\"/usr/local/mercury-rotd-2022-01-09/lib/mercury/elisp\") \n\
(autoload 'mdb \"gud\" \"Invoke the Mercury debugger\" t)" >> /root/.emacs
RUN rm -rf /emacs
RUN echo '#!/bin/bash \n\
PATH0=$PATH \n\
PATH=/usr/local/mercury-DEV/bin:$PATH mmc "$@" \n\
PATH=$PATH0' > /usr/local/bin/mmc-dev && chmod +x /usr/local/bin/mmc-dev
RUN echo '#!/bin/bash \n\
PATH0=$PATH \n\
PATH=/usr/local/mercury-DEV/bin:$PATH mmake "$@" \n\
PATH=$PATH0' > /usr/local/bin/mmake-dev && chmod +x /usr/local/bin/mmake-dev
RUN apt -y autoremove --purge && apt -y clean


