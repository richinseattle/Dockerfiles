FROM ubuntu:xenial
MAINTAINER Richard Johnson “rjohnson@moflow.org”

# Currently broken, work in progress


ENV GCC /gcc-trunk
RUN apt-get -y update && \
    apt-get -y install subversion build-essential flex bison libc6-dev libc6-dev-i386 \
                       linux-libc-dev libgmp3-dev libmpfr-dev libmpc-dev && \
    svn checkout svn://gcc.gnu.org/svn/gcc/trunk $GCC && \
    ( cd $GCC && \
      svn ls -v ^/tags | grep gcc_6_1_0_release   && \
      svn up -r 235474    && \
      mkdir build         && \
      mkdir install       && \
      cd build/           && \
      ../configure --enable-languages=c,c++ --disable-bootstrap --enable-checking=no \
                   --with-gnu-as --with-gnu-ld --with-ld=/usr/bin/ld.bfd --disable-multilib \
                   --prefix=$GCC/install/   && \
      make && \
      make install )

ENV KERNEL /kernel-git
RUN git clone https://github.com/torvalds/linux.git $KERNEL
    ( cd $KERNEL
    make defconfig
    make kvmconfig
    # Edit .config to set CONFIG_KCOV=y
    # Edit .config to set CONFIG_DEBUG_INFO=y
    # Edit .config to set CONFIG_KASAN=y
    make oldconfig
    # Select KASAN_INLINE when prompted, leave other options default
    make CC='$GCC/install/bin/gcc' -j )

RUN apt-get -y install debootstrap && \
    https://github.com/google/syzkaller/blob/master/tools/create-image.sh && \
    bash create-image.sh && \
    chroot wheezy /bin/bash -c "apt-get -y install -y curl tar time strace gcc make sysbench git vim screen usbutils" && \
    chroot wheezy /bin/bash -c "mkdir -p ~; cd ~/; wget https://github.com/kernelslacker/trinity/archive/v1.5.tar.gz -O trinity-1.5.tar.gz; tar -xf trinity-1.5.tar.gz"  && \
    chroot wheezy /bin/bash -c "cd ~/trinity-1.5 ; ./configure.sh ; make -j ; make install" && \
    cp -r $KERNEL wheezy/tmp/ && \
    chroot wheezy /bin/bash -c "apt-get install -y flex bison python-dev libelf-dev libunwind7-dev libaudit-dev libslang2-dev libperl-dev binutils-dev liblzma-dev libnuma-dev" && \
    chroot wheezy /bin/bash -c "cd /tmp/linux/tools/perf/; make" && \
    chroot wheezy /bin/bash -c "cp /tmp/linux/tools/perf/perf /usr/bin/" && \
    rm -r wheezy/tmp/linux

RUN apt-get -y install kvm qemu-kvm

RUN apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*


CMD /bin/bash
