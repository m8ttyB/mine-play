FROM alpine:3.13 AS builder

ARG XMRIG_VERSION='v6.15.3'
WORKDIR /miner

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    build-base \
    git \
    cmake \
    libuv-dev \
    libressl-dev \ 
    hwloc-dev@community

RUN git clone https://github.com/xmrig/xmrig && \
    mkdir xmrig/build && \
    cd xmrig && git checkout ${XMRIG_VERSION}


RUN cd xmrig/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)


FROM alpine:3.13

# ENV WALLET=49FzQ7CxFxLQsYNHnGJ8CN1BgJaBvr2FGPEiFVcbJ7KsWDRzSxyN8Sq4hHVSYehjPZLpGe26cY8b7PShd7yxtZcrRjz6xdT
# ENV POOL=rx-us.unmineable.com:3333
# ENV WORKER_NAME=docker

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    libuv \
    libressl \ 
    hwloc@community

WORKDIR /xmr
COPY --from=builder /miner/xmrig/build/xmrig /xmr

CMD ["sh", "-c", "./xmrig -o rx-us.unmineable.com:3333 -u SHIB:0x15e11412D6aDAbB5bCB663c966343997afF53Ba3 -p docker_1"]
