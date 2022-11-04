FROM ubuntu:bionic

RUN apt-get update -y

RUN apt-get install -y \
  build-essential \
  libmicrohttpd-dev \
  libjansson-dev \
  libssl-dev \
  libsofia-sip-ua-dev \
  libglib2.0-dev \
  libopus-dev \
  libogg-dev \
  libcurl4-openssl-dev \
  liblua5.3-dev \
  libconfig-dev \
  pkg-config \
  gengetopt \
  libtool \
  automake \
  libavcodec-dev \
  libavformat-dev \
  libavutil-dev \
  make \
  git \
  cmake \
  sudo


RUN cd ~ \
  && apt-get install -y python3-pip \
  && sudo pip3 install meson ninja \
  && git clone https://gitlab.freedesktop.org/libnice/libnice \
  && cd libnice \
  && sudo meson --prefix=/usr build && sudo ninja -C build && sudo ninja -C build install


RUN cd ~ \
  && git clone https://github.com/cisco/libsrtp.git \
  && cd libsrtp \
  && git checkout v2.2.0 \
  && ./configure --prefix=/usr --enable-openssl \
  && make shared_library \
  && sudo make install

RUN cd ~ \
  && git clone https://github.com/sctplab/usrsctp \
  && cd usrsctp \
  && ./bootstrap \
  && ./configure --prefix=/usr \
  && make \
  && sudo make install


RUN cd ~ \
  && git clone https://github.com/warmcat/libwebsockets.git \
  && cd libwebsockets \
  && git checkout v3.2-stable \
  && mkdir build \
  && cd build \
  && cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
  && make \
  && sudo make install

RUN cd ~ \
  && git clone https://github.com/meetecho/janus-gateway.git --branch v1.1.0 --depth 1 \
  && cd janus-gateway \
  && sh autogen.sh \
  && ./configure --prefix=/opt/janus --enable-post-processing --disable-aes-gcm \
  && make \
  && sudo make install \
  && sudo make configs

#   && ./configure --prefix=/opt/janus --enable-post-processing --enable-openssl --disable-aes-gcm \
# RUN cp -rp ~/janus-gateway/certs /opt/janus/share/janus

COPY conf/*.jcfg /opt/janus/etc/janus/

# RUN apt-get install nginx -y
# COPY nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 7088 8088 8188 8089
EXPOSE 10000-10200/udp

# CMD service nginx restart && /opt/janus/bin/janus 
CMD /opt/janus/bin/janus
# -r 10000-10200
# --nat-1-1=${DOCKER_IP}