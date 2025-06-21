#!/bin/sh
# TODO: We need a nice way to select specific target platforms
meson setup build --reconfigure \
  -Dintel=disabled \
  -Dradeon=enabled \
  -Damdgpu=enabled \
  -Dnouveau=disabled \
  -Dvmwgfx=disabled \
  -Domap=disabled \
  -Dfreedreno=disabled \
  -Dtegra=disabled \
  -Detnaviv=disabled \
  -Dman-pages=disabled \
  -Dvalgrind=disabled \
  -Dfreedreno-kgsl=false \
  -Dinstall-test-programs=false \
  -Dudev=false \
  -Dtests=false \
  -Dprefix=/usr
