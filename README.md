# Scripts / notes related to running GHC/stack on ARMv7 SBC linux systems.

Cross compilation is difficult and building on low-end boards takes a very long time.
The basic approach here is to use QEMU/binfmt/docker and build on an x86_64 system.

To simplify management of docker images they only contain OS and basic dependencies.
GHC/stack are mounted as a volume from a local directory.

If your user ID is anything but 1000 you may need to wrap this docker image with another one
that adds your user/group. Otherwise you'll run into permission problems with the mounted local directories.


## Pre-requisites

```
Ubuntu 16.04 LTS. Worked with 14.04 as well but 16.04 runs QEMU better.
My kernel version at the moment is 4.4.0-22-generic x86_64.
QEMU at the moment is qemu-user-static 1:2.5+dfsg-5ubuntu10.1.
Binformat version is binfmt-support: 2.1.6-1.
Docker version is 1.11.2.
```

## Running

Take a look at an example platform [script](bin/docker-haskell-platform-armv7l).
Adjust to your liking. In my case ARM version of stack binaries looks like

```
/home/andrey/.armv7l/
└── debian-jessie-cortex-a15
    ├── cabal
    ├── local
    │   └── bin
    │       ├── alex
    │       ├── happy
    │       ├── stack
    │       ├── stack-1.0.0-arm
    │       ├── stack-1.0.2-arm
    │       └── stack-1.1.0-arm
    └── stack
        ├── build-plan
        ├── build-plan-cache
        ├── config.yaml
        ├── global-project
        ├── indices
        ├── precompiled
        ├── programs
        ├── setup-exe-cache
        └── snapshots

```

If you trust a binary produced by some random dude (which you really shouldn't) -
 grab a [stack binary](https://gist.github.com/andreyk0/07273aa2cedbaa2f469468005438e92b) and download an
official [GHC](https://www.haskell.org/ghc/download).
At the moment stack doesn't manage GHC binaries on ARM, so, you'll need to install them following stack's convention under (in my case):
```
~/.armv7l/debian-jessie-cortex-a15/stack/programs/arm-linux# ll
total 12
lrwxrwxrwx 1 andrey andrey   10 Dec 15 22:48 ghc-7.10.2 -> ghc-7.10.3/
-rw-rw-r-- 1 andrey andrey   10 Dec 15 22:48 ghc-7.10.2.installed
drwxr-xr-x 5 andrey andrey 4096 Dec 15 22:44 ghc-7.10.3/
-rw-rw-r-- 1 andrey andrey   10 Dec 15 22:48 ghc-7.10.3.installed
```

Notice that 7.10.2 version is hacked to point to 7.10.3. This works in practice and not a terrible idea as each GHC
 release tends to fix at least a few ARM-related bugs.


Here's how to initialize, step by step (using ghc8 as an example, steps are the same for 7.10 branch) using paths from the [platform script](bin/docker-haskell-platform-armv7l):


Set up directories mounted to platform docker container as volumes:

```
# mkdir -pv ~/.armv7l/debian-jessie-cortex-a15/local/bin
# mkdir -pv ~/.armv7l/debian-jessie-cortex-a15/cabal
# mkdir -pv ~/.armv7l/debian-jessie-cortex-a15/stack
```

Download ARM stack binary:

```
# cd ~/.armv7l/debian-jessie-cortex-a15/local/bin
# wget -O stack.gz https://gist.github.com/andreyk0/07273aa2cedbaa2f469468005438e92b/raw/755a21c5d2169037a6a80504bbcd57d9bdad6666/stack.gz
# gunzip stack.gz
# chmod 755 stack
```

Launch platform image (those local, cabal and stack directories are mounted as ~/.local, ~/.cabal and ~/.stack now):

```
# bin/docker-haskell-platform-armv7l jessie /bin/bash
# export PATH=$HOME/.local/bin:$PATH
# which stack
/home/andrey/.local/bin/stack
#
# stack setup
```

Stack setup will run for a while but complain that it doesn't know how to install GHC:

```
I don't know how to install GHC for (Linux,Arm), please install manually
```

Download GHC (outside of the docker container to make it run faster):

```
# cd .armv7l/debian-jessie-cortex-a15/stack/programs/arm-linux
# wget http://downloads.haskell.org/~ghc/8.0.1/ghc-8.0.1-armv7-deb8-linux.tar.xz
# tar xf ghc-8.0.1-armv7-deb8-linux.tar.xz
```

Install GHC (continuing inside the docker container):

```
# cd ~/.stack/programs/arm-linux
# mv ghc-8.0.1 ghc-8.0.1-dist # tar.xz uses same dir name as the target
# rm ghc-8.0.1-armv7-deb8-linux.tar.xz
# cd ghc-8.0.1-dist
# ./configure --prefix ~/.stack/programs/arm-linux/ghc-8.0.1
# make install
# cd ~/.stack/programs/arm-linux
# rm -rf ghc-8.0.1-dist
#
# touch ghc-8.0.1.installed
#
```

Follow the same steps to install 7.10.3 branch and you'll have a working environment capable of building [stackage](https://www.stackage.org/) packages for ARM.
In practice the binaries produced with this environment are fairly portable because most of the stuff is linked in statically and debian itself targets many systems.



## Using

Run stack:

```
# docker-haskell-platform-armv7l jessie stack --version
Version 1.1.0 arm hpack-0.13.0
```

Run shell:

```
# docker-haskell-platform-armv7l jessie /bin/bash
debian@f2e21cb6b981:~/a$ uname -a
Linux f2e21cb6b981 4.4.0-22-generic #40-Ubuntu SMP Thu May 12 22:03:46 UTC 2016 armv7l GNU/Linux
debian@f2e21cb6b981:~/a$
```


## Build docker images

andreyk0/haskell-platform-armhf-debian-jessie - all GHC dependencies without the GHC itself.
andreyk0/armhf-debian-jessie - base debian jessie image, taken from an SD card right after minimal install.


```
make create-armhf-debian-jessie-image  -- base OS docker image
make publish-armhf-debian-jessie-image -- publishes ^^ to registry

make create-haskell-platform-armhf-debian-jessie  -- adds packages required to run ghc to base
make publish-haskell-platform-armhf-debian-jessie -- publishes ^^ to registry
```
