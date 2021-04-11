FROM ubuntu:focal

RUN apt-get update \
  && apt-get -y install \
    ca-certificates \
    parted \
    wget \
    xz-utils \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/*

