# Scripts / notes related to running GHC/stack on ARMv7 SBC linux systems.


## Build docker images

andreyk0/haskell-platform-armhf-debian-jessie - all GHC dependencies without the GHC itself.
andreyk0/armhf-debian-jessie - base debian jessie image, taken from an SD card right after minimal install.


```
make create-armhf-debian-jessie-image  -- base OS docker image
make publish-armhf-debian-jessie-image -- publishes ^^ to registry

make create-haskell-platform-armhf-debian-jessie  -- adds packages required to run ghc to base
make publish-haskell-platform-armhf-debian-jessie -- publishes ^^ to registry
```
