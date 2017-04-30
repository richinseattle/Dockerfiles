FROM ioft/i386-ubuntu:trusty
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# VUzzer - https://github.com/vusec/vuzzer

RUN apt-get -y update && \
    apt install -y git build-essential wget python2.7 bmagic python-pip && \
    pip install bitvector

RUN git clone https://github.com/lemire/EWAHBoolArray.git && \
    cd EWAHBoolArray && cp headers/* /usr/include

RUN wget http://software.intel.com/sites/landingpage/pintool/downloads/pin-2.14-71313-gcc.4.4.7-linux.tar.gz && \
    tar zxf pin-2.14-71313-gcc.4.4.7-linux.tar.gz && \
    rm -rf pin-2.14-71313-gcc.4.4.7-linux/intel64

ENV PIN_ROOT /pin-2.14-71313-gcc.4.4.7-linux

RUN git clone https://github.com/vusec/vuzzer.git && \
    cd vuzzer && ln -s ../pin-2.14-71313-gcc.4.4.7-linux pin && \
    make support-libdft && make TARGET=ia32 && make -f mymakefile TARGET=ia32

CMD /bin/bash
