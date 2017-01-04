FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# AFL TriforceLinuxSyscallFuzzer

ENV K kern

RUN apt-get -y update && \
    apt-get -y build-dep qemu && \
    apt-get -y install build-essential curl git \
    	libtool-bin wget automake bison \
    	linux-image-$(uname -r) && \
    git clone https://github.com/nccgroup/TriforceAFL.git && \
    ( cd TriforceAFL && make ) && \
    git clone https://github.com/nccgroup/TriforceLinuxSyscallFuzzer.git && \
    ( cd TriforceLinuxSyscallFuzzer && \
      make && \
      mkdir kern && \
      cp /boot/vmlinuz* kern/bzImage && \
      cp /boot/System.map* kern/kallsyms && \
      make inputs ) && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /TriforceLinuxSyscallFuzzer
CMD ./runFuzz -M M0
