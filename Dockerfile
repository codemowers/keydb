FROM alpine AS build
RUN apk add bash build-base coreutils curl-dev git libunwind-dev linux-headers musl-dev openssl-dev perl util-linux-dev snappy-dev bzip2-dev zstd-dev lz4-dev
WORKDIR /tmp
RUN git clone --branch v6.3.2 https://github.com/Snapchat/KeyDB.git --recursive;
WORKDIR /tmp/KeyDB
RUN make -j$(nproc) BUILD_TLS=yes;
WORKDIR /tmp/KeyDB/src
RUN strip keydb-server keydb-cli

FROM alpine
RUN apk add snappy libbz2 zstd-libs lz4-libs
COPY --from=build /tmp/KeyDB/src/keydb-server /tmp/KeyDB/src/keydb-cli /usr/local/bin/
RUN apk add libcurl libuuid libgcc libunwind libstdc++ bash
RUN ldd /usr/local/bin/keydb-server /usr/local/bin/keydb-cli
RUN ln -s /usr/local/bin/keydb-cli /usr/local/bin/redis-cli
ADD entrypoint.sh liveness.sh readiness.sh /
VOLUME /data
WORKDIR /data
EXPOSE 6379
ENTRYPOINT ["/entrypoint.sh"]
