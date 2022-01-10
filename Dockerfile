# name the portage image
# for apt to be noninteractive
FROM ubuntu:21.10
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN apt update && apt upgrade -y
# build essentials
RUN apt install -y wget git xz-utils build-essential flex bison libtool texinfo info \
                   libgif-dev libgnutls28-dev mailutils pkg-config \
                   libncurses-dev libxaw7-dev libjpeg-dev libpng-dev libtiff-dev
RUN apt autoremove -y
# download auxiliary ROTD build, to bootstrap image building
RUN wget https://github.com/fabnicol/ubuntu4mercury/releases/download/v1.0/rotd.tar.xz
RUN tar xJvf rotd.tar.xz && rm rotd.tar.xz 
RUN echo PATH='/usr/local/mercury-rotd-2022-01-09/bin:$PATH' >> /etc/profile
RUN wget https://github.com/Mercury-Language/mercury-srcdist/archive/refs/tags/rotd-2022-01-09.tar.gz 
RUN tar xzvf rotd-2022-01-09.tar.gz
RUN echo 'source /etc/profile' >> /root/.bashrc
# rebuild the same ROTD within the docker image for security-minded users
RUN cd mercury-srcdist-rotd-2022-01-09 && /bin/bash /root/.bashrc && /bin/bash configure && make install PARALLEL=-j4 
RUN rm -rf /mercury-srcdist-rotd-2022-01-09
# now with this secured ROTD build the Mercury git source
RUN git clone --depth=1 -b master --single-branch https://github.com/Mercury-Language/mercury.git
# synchronize the ROTD and git source dates otherwise it may not build
RUN cd mercury && git reset --hard 06f81f1cf0d339ade0137bc2e145712872cecd59
RUN /bin/bash /etc/profile && ./prepare.sh 
RUN /bin/bash configure --disable-most-grades && make install PARALLEL=-j4 
RUN echo PATH='$PATH:/usr/local/mercury-DEV/bin' >> /etc/profile
RUN rm -rf /mercury
# do the same for emacs, with Mercury support for etags (source code tagging)
RUN git clone --depth=1 -b master --single-branch git://git.sv.gnu.org/emacs.git
RUN cd emacs && /bin/bash /etc/profile && ./autogen.sh
RUN /bin/bash configure --prefix=/usr/local/emacs-DEV && make install -j4 
# adjust paths and cleanup
RUN echo PATH='$PATH:/usr/local/emacs-DEV/bin' >> /etc/profile
RUN echo MANPATH='$MANPATH:/usr/local/mercury-rotd-2022-01-09/man' >> /etc/profile
RUN echo INFOPATH='$INFOPATH:/usr/local/mercury-rotd-2022-01-09/info' >> /etc/profile
RUN echo "(add-to-list 'load-path \
"/usr/local/mercury-rotd-2022-01-09/lib/mercury/elisp") \
(autoload 'mdb "gud" "Invoke the Mercury debugger" t)" >> /root/.emacs
RUN rm -rf /emacs


