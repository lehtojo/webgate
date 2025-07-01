#!/bin/sh
# TODO: We need a nice way to select specific drivers
meson setup build --reconfigure \
  -Dplatforms= \
  -Dgallium-drivers=radeonsi,llvmpipe,softpipe \
  -Dglx=disabled \
  -Dlmsensors=disabled \
  -Dllvm=true \
  -Ddraw-use-llvm=true \
  -Dbuildtype=release \
  -Dprefix=/usr
