FROM ubuntu:trusty
MAINTAINER Richard Johnson “rjohnson@moflow.org”

RUN apt-get -y update && \
    apt-get -y install build-essential git \
    dialog libstdc++6 python && \
    git clone https://github.com/trailofbits/mcsema.git && \
    cd mcsema && \
    ./bootstrap.sh
