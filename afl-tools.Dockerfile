FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# American Fuzzy Lop w/ clang, qemu, dyninst, triforce support

# AFL standard binaries are installed to /usr/local/bin
# AFL qemu build is in /afl/qemu_mode
# afl-dyninst is installed to /usr/local/*
# Patched AFL binaries for TriforceAFL are in /TriforceAFL
# TriforceLinuxSyscallFuzzer is configured for fuzzing current kernel image

# afl-analyze  afl-clang-fast    afl-fuzz  afl-gotcpu   afl-tmin
# afl-clang    afl-clang-fast++  afl-g++   afl-plot     afl-whatsup
# afl-clang++  afl-cmin          afl-gcc   afl-showmap
# afl-dyninst  afl-qemu-trace    afl-qemu-system-trace


# afl w/ llvm + qemu

RUN apt-get -y update && \
    apt-get -y install build-essential curl clang git \
      libtool-bin wget automake bison \
      cmake libelf-dev libelf1 libiberty-dev libboost-all-dev  && \
    apt-get -y build-dep qemu && \

    curl -L http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz | tar zxf - && \
    ( cd afl-* && make ) && \
    
    ln -s /usr/bin/llvm-config-3.8 /usr/bin/llvm-config && \
    ( cd afl-*/llvm_mode && make ) && \

    ( cd afl-*/qemu_mode && ./build_qemu_support.sh ) && \

    ( cd afl-* && make install ) && \
    ln -s `ls -1d afl-* | head -1` afl && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*


# afl-dyninst

RUN curl -L https://github.com/dyninst/dyninst/archive/v9.2.0.tar.gz | \
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
    rm -rf /dyninst-9.2.0 

ENV DYNINSTAPI_RT_LIB /usr/local/lib/libdyninstAPI_RT.so


# Triforce

ENV K kern
RUN git clone https://github.com/nccgroup/TriforceAFL.git && \
    ( cd TriforceAFL && make ) && \
    apt-get -y update && \
    apt-get -y install linux-image-$(uname -r) && \
    git clone https://github.com/nccgroup/TriforceLinuxSyscallFuzzer.git && \
    ( cd TriforceLinuxSyscallFuzzer && \
      make && \
      mkdir kern && \
      cp /boot/vmlinuz* kern/bzImage && \
      cp /boot/System.map* kern/kallsyms && \
      make inputs ) && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*


CMD /usr/local/bin/afl-fuzz
