FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# American Fuzzy Lop w/ clang and dyninst support

# afl-analyze  afl-clang-fast    afl-fuzz  afl-gotcpu   afl-tmin
# afl-clang    afl-clang-fast++  afl-g++   afl-plot     afl-whatsup
# afl-clang++  afl-cmin          afl-gcc   afl-showmap
# afl-dyninst

RUN apt-get -y update && \
    apt-get -y install build-essential curl clang git && \
	  ln -s /usr/bin/llvm-config-3.8 /usr/bin/llvm-config && \
	  curl -L http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz | tar zxf - && \
	  ( cd afl-* && make ) && \
	  ( cd afl-*/llvm_mode && make ) && \
	  ( cd afl-* && make install ) && \
	  ln -s `ls -1d afl-* | head -1` afl && \
	  apt-get install -y cmake libelf-dev libelf1 libiberty-dev libboost-all-dev  && \
	  curl -L https://github.com/dyninst/dyninst/archive/v9.2.0.tar.gz | \
  	tar zxf - && \
	  ( cd dyninst-9.2.0 && \
	    mkdir build && cd build && \
      cmake .. && \
      make && \
      make install ) && \
	  git clone https://github.com/talos-vulndev/afl-dyninst.git && \
    ( cd afl-dyninst && \
      ln -s ../afl-* afl && \
      make && \
      cp afl-dyninst /usr/bin && \
      cp libAflDyninst.so /usr/local/lib ) && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/dyninst.conf && ldconfig && \
   	rm -rf /afl-* && \
    rm -rf dyninst-9.2.0 
  	apt-get -y autoremove && \
	  rm -rf /var/lib/apt/lists/*

ENV DYNINSTAPI_RT_LIB /usr/local/lib/libdyninstAPI_RT.so

CMD /usr/local/bin/afl-fuzz
