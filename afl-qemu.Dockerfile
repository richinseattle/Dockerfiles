FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# American Fuzzy Lop w/ qemu userland support

# afl-analyze  afl-clang  afl-clang++  afl-cmin  afl-fuzz  afl-g++  
# afl-gcc  afl-gotcpu  afl-plot  afl-showmap  afl-tmin  afl-whatsup
# afl-qemu-trace

RUN apt-get -y update && \
    apt-get -y build-dep qemu && \
    apt-get -y install build-essential curl libtool-bin wget automake bison && \
    curl -L http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz | tar zxf - && \
    ( cd afl-* && make ) && \
    ( cd afl-*/qemu_mode && ./build_qemu_support.sh ) && \
    ( cd afl-* && make install ) && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

CMD /usr/local/bin/afl-fuzz
