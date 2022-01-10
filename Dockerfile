# name the portage image
#FROM ubuntu:latest 
## for apt to be noninteractive
FROM ubuntu:21.10
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN apt update && apt upgrade -y
RUN apt install -y wget git xz-utils build-essential flex bison libtool texinfo info \
                   libgif-dev libgnutls28-dev mailutils pkg-config \
                   libncurses-dev libxaw7-dev libjpeg-dev libpng-dev libtiff-dev
RUN apt autoremove -y
RUN wget https://github.com/fabnicol/ubuntu4mercury/releases/download/v1.0/rotd.tar.xz
RUN tar xJvf rotd.tar.xz && rm rotd.tar.xz 
RUN echo PATH='/usr/local/mercury-rotd-2022-01-09/bin:$PATH' >> /etc/profile
RUN wget https://github.com/Mercury-Language/mercury-srcdist/archive/refs/tags/rotd-2022-01-09.tar.gz 
RUN tar xzvf rotd-2022-01-09.tar.gz && cd mercury-srcdist-rotd-2022-01-09 
RUN echo 'source /etc/profile' >> /root/.bashrc
RUN source /etc/profile && ./configure && make install PARALLEL=-j4 
RUN rm -rf /mercury-srcdist-rotd-2022-01-09
RUN git clone --depth=1 -b master --single-branch https://github.com/Mercury-Language/mercury.git
RUN cd mercury && source /etc/profile && ./prepare.sh 
RUN ./configure --disable-most-grades && make install PARALLEL=-j4 
RUN echo PATH='$PATH:/usr/local/mercury-DEV/bin' >> /etc/profile
RUN rm -rf /mercury
RUN git clone --depth=1 -b master --single-branch git://git.sv.gnu.org/emacs.git
RUN cd emacs && source /etc/profile && ./autogen.sh
RUN ./configure --prefix=/usr/local/emacs-DEV && make install -j4 
RUN echo PATH='$PATH:/usr/local/emacs-DEV/bin' >> /etc/profile
RUN echo MANPATH='$MANPATH:/usr/local/mercury-rotd-2022-01-09/man' >> /etc/profile
RUN echo INFOPATH='$INFOPATH:/usr/local/mercury-rotd-2022-01-09/info' >> /etc/profile
RUN rm -rf /emacs
RUN echo "(add-to-list 'load-path \
"/usr/local/mercury-rotd-2022-01-09/lib/mercury/elisp") \
(autoload 'mdb "gud" "Invoke the Mercury debugger" t)" >> /root/.emacs

# Do not use &

