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


# LLVM version that GHC likes
ADD clang+llvm-3.5.2-armv7a-linux-gnueabihf.tar.xz /usr/local


# this is necessary for tools to find LLVM under standard locations
RUN ln -s /usr/local/bin/opt /usr/bin/opt-3.5 \
 && ln -s /usr/local/bin/llc /usr/bin/llc-3.5 \
 && ln -s /usr/local/bin/lli /usr/bin/lli-3.5


# Remove tmp files
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
