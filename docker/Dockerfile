FROM ubuntu:18.04
LABEL maintainer="yu"

RUN apt-get update \
 && apt-get -y install \
    build-essential    \
    ccache             \
    cmake              \
    curl               \
    gfortran           \
    git                \
    libmetis-dev       \
    libmetis5          \
    libmumps-dev       \
    libopenblas-dev    \
    libopenmpi-dev     \
    libptscotch-dev    \
    ruby               \
    trilinos-all-dev   \
 && apt-get clean      \
 && rm -rf /var/lib/apt/lists/*

COPY ninja /usr/bin/
