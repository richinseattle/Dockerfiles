FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# American Fuzzy Lop including clang and qemu userland support
# afl-dyninst for statically rewriting AFL support into ELF binaries
# TriforceAFL for kernel fuzzing support

# TODO: build llvm from SVN to enable trace-pc mode in afl-clang


### AFL with clang and qemu support 
###############################################################################

RUN apt-get -y update && \
	apt install -y \
		git \
		libglib2.0-dev \
		zlib1g-dev \
		gcc-5-plugin-dev \
		libtool-bin \
		wget \
		automake \
		bison \
		curl && \
	apt-get -y build-dep afl && \
	apt-get -y build-dep qemu

RUN curl -L http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz | \
  tar zxf - && \
	ln -s `ls -1d afl-*` afl && \
	cd afl && \
	make && \
	( cd qemu_mode && ./build_qemu_support.sh ) && \
	ln -s /usr/bin/clang-3.6 /usr/bin/clang && \
	ln -s /usr/bin/clang++-3.6 /usr/bin/clang++ && \
	ln -s /usr/bin/llvm-config-3.6 /usr/bin/llvm-config && \
	( cd llvm_mode && make )

### afl-dyninst (static ELF rewriter for fast closed source fuzzing)
###############################################################################

RUN apt-get install -y \
        cmake \
        libelf-dev \
        libelf1 \
        libiberty-dev \
        libboost-all-dev 

RUN curl -L https://github.com/dyninst/dyninst/archive/v9.2.0.tar.gz | \
  tar zxf - && \
	cd dyninst-9.2.0 && \
	mkdir build && cd build && \
    cmake .. && \
    make && \
    make install

RUN git clone https://github.com/talos-vulndev/afl-dyninst.git && \
    cd afl-dyninst && \
    ln -s ../afl afl && \
    make && \
    cp afl-dyninst /usr/bin && \
    cp libAflDyninst.so /usr/local/lib/ && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/dyninst.conf && ldconfig 
    
ENV DYNINSTAPI_RT_LIB /usr/local/lib/libdyninstAPI_RT.so


### TriforceLinuxSyscallFuzzer (kernel fuzz with qemu + afl)
###############################################################################

RUN git clone https://github.com/nccgroup/TriforceAFL.git && \
	cd TriforceAFL && make

ENV K kern
RUN git clone https://github.com/nccgroup/TriforceLinuxSyscallFuzzer.git && \
	cd TriforceLinuxSyscallFuzzer && \
	make && \
	mkdir kern && \
	apt-get -y install linux-image-$(uname -r) && \
	cp /boot/vmlinuz* kern/bzImage && \
	cp /boot/System.map* kern/kallsyms && \
	make inputs 


###############################################################################

CMD /bin/bash

#WORKDIR /TriforceLinuxSyscallFuzzer
#CMD ./runFuzz -M M0
