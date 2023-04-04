FROM ubuntu:18.04 AS build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  dpkg-dev pkg-config ca-certificates build-essential nasm autotools-dev \
  autoconf libjemalloc-dev tcl tcl-dev uuid-dev libcurl4-openssl-dev \
  libbz2-dev libzstd-dev liblz4-dev libsnappy-dev libssl-dev git
WORKDIR /tmp
RUN git clone --branch RELEASE_6_3_2 https://github.com/Snapchat/KeyDB.git --recursive;
WORKDIR /tmp/KeyDB
RUN make -j$(nproc) BUILD_TLS=yes ENABLE_FLASH=yes
WORKDIR /tmp/KeyDB/src
RUN strip keydb-cli keydb-benchmark keydb-check-rdb keydb-check-aof keydb-diagnostic-tool keydb-server

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y --no-install-recommends \
  libssl1.1 libsnappy1v5 libcurl4
COPY --from=build \
  /tmp/KeyDB/src/keydb-cli \
  /tmp/KeyDB/src/keydb-benchmark \
  /tmp/KeyDB/src/keydb-check-rdb \
  /tmp/KeyDB/src/keydb-check-aof \
  /tmp/KeyDB/src/keydb-diagnostic-tool \
  /tmp/KeyDB/src/keydb-server \
  /usr/local/bin/
RUN ln -s /usr/local/bin/keydb-cli /usr/local/bin/redis-cli
ADD entrypoint.sh liveness.sh readiness.sh /
VOLUME /data
WORKDIR /data
EXPOSE 6379
ENTRYPOINT ["/entrypoint.sh"]
