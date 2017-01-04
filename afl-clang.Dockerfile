FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# American Fuzzy Lop w/ clang support

# afl-analyze  afl-clang-fast    afl-fuzz  afl-gotcpu   afl-tmin
# afl-clang    afl-clang-fast++  afl-g++   afl-plot     afl-whatsup
# afl-clang++  afl-cmin          afl-gcc   afl-showmap

RUN apt-get -y update && \
    apt-get -y build-dep llvm && \
    apt-get -y install curl clang && \
	ln -s /usr/bin/llvm-config-3.8 /usr/bin/llvm-config && \
	curl -L http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz | tar zxf - && \
	( cd afl-* && make ) && \
	( cd afl-*/llvm_mode && make ) && \
	( cd afl-* && make install ) && \
	rm -rf /afl-* && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

CMD /usr/local/bin/afl-fuzz
