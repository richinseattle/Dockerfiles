FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# American Fuzzy Lop w/ clang and dyninst support

# afl-analyze  afl-clang-fast    afl-fuzz  afl-gotcpu   afl-tmin
# afl-clang    afl-clang-fast++  afl-g++   afl-plot     afl-whatsup
# afl-clang++  afl-cmin          afl-gcc   afl-showmap
# afl-dyninst

RUN apt-get -y update && \
    apt-get -y install build-essential curl clang git \
      cmake libelf-dev libelf1 libiberty-dev libboost-all-dev  && \
    ln -s /usr/bin/llvm-config-3.8 /usr/bin/llvm-config && \
    curl -L http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz | tar zxf - && \
    ( cd afl-* && make ) && \
    ( cd afl-*/llvm_mode && make ) && \
    ( cd afl-* && make install ) && \
    ln -s `ls -1d afl-* | head -1` afl && \
    curl -L https://github.com/dyninst/dyninst/archive/v9.2.0.tar.gz | \
    tar zxf - && \
    ( cd dyninst-9.2.0 && \
      mkdir build && cd build && \
      cmake .. && \
      make && \
      make install ) && \
    git clone https://github.com/talos-vulndev/afl-dyninst.git && \
    ( cd afl-dyninst && \
      ln -s ../afl afl && \
      make && \
      cp afl-dyninst /usr/local/bin && \
      cp libAflDyninst.so /usr/local/lib ) && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/dyninst.conf && ldconfig && \
    rm -rf /afl* && \
    rm -rf dyninst-9.2.0 && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* \
    echo -ne \
        "Usage: afl-dyninst -i <binary> -o <binary> -l <library> -e <address> -s <number>\n" \
        "    -i: Input binary\n" \
        "    -o: Output binary\n" \
        "    -d: Don't instrument the binary, only supplied libraries\n" \
        "    -l: Linked library to instrument (repeat for more than one)\n" \
        "    -r: Runtime library to instrument (path to, repeat for more than one)\n" \
        "    -e: Entry point address to patch (required for stripped binaries)\n" \
        "    -s: Number of basic blocks to skip\n" \
        "    -v: Verbose output\n" \
        > /etc/motd

ENV DYNINSTAPI_RT_LIB /usr/local/lib/libdyninstAPI_RT.so

CMD afl-dyninst
