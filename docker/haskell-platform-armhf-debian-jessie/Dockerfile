#
# https://github.com/andreyk0/haskell-on-arm
#
# User: debian
# Passwd: /dev/null
#
FROM andreyk0/armhf-debian-jessie:20160609

# A CPU that works, for reference, this shouldn't
# matter much for the compiled binaries as debian
# restricts some CPU settings to enable broader compatibility.
ENV QEMU_SET_ENV=QEMU_CPU=cortex-a15

# These are needed for ghc toolchain to work
RUN    apt-get update -y \
    && apt-get install -y \
               alex \
               binutils-gold \
               build-essential \
               ca-certificates \
               happy \
               libffi-dev \
               libgmp-dev \
               libpcre3-dev \
               libv4l-dev \
               zlib1g-dev


# LLVM version that GHC 7.10 likes
COPY clang+llvm-3.5.2-armv7a-linux-gnueabihf.tar.xz /usr/local/llvm-3.5.tar.xz
RUN tar xvf /usr/local/llvm-3.5.tar.xz -C /usr/local --strip-components 1
# this is necessary for tools to find LLVM under standard locations
RUN ln -s /usr/local/llvm-3.5/bin/opt /usr/bin/opt-3.5 \
 && ln -s /usr/local/llvm-3.5/bin/llc /usr/bin/llc-3.5 \
 && ln -s /usr/local/llvm-3.5/bin/lli /usr/bin/lli-3.5


# LLVM version that GHC 8.0 likes
COPY clang+llvm-3.7.1-armv7a-linux-gnueabihf.tar.xz /usr/local/llvm-3.7.tar.xz
RUN tar xvf /usr/local/llvm-3.7.tar.xz -C /usr/local --strip-components 1
# this is necessary for tools to find LLVM under standard locations
RUN ln -s /usr/local/llvm-3.7/bin/opt /usr/bin/opt-3.7 \
 && ln -s /usr/local/llvm-3.7/bin/llc /usr/bin/llc-3.7 \
 && ln -s /usr/local/llvm-3.7/bin/lli /usr/bin/lli-3.7


# Remove tmp files
RUN rm /usr/local/*.tar.*
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
