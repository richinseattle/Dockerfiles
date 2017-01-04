FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# American Fuzzy Lop

# afl-analyze  afl-clang  afl-clang++  afl-cmin  afl-fuzz  afl-g++  
# afl-gcc  afl-gotcpu  afl-plot  afl-showmap  afl-tmin  afl-whatsup

RUN apt-get -y update && \
    apt-get -y install \
		build-essential \
		curl && \
	curl -L http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz | tar zxf - && \
	( cd afl-* && make && make install ) && \
	rm -rf /afl-* && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

CMD /usr/local/bin/afl-fuzz
