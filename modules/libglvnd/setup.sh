#!/bin/sh
meson setup build --reconfigure \
  -Dasm=enabled \
  -Dx11=disabled \
  -Degl=true \
  -Dglx=disabled \
  -Dhgl=false \
  -Dgles1=true \
  -Dgles2=true \
  -Dtls=true \
  -Ddispatch-tls=true \
  -Ddispatch-page-size=0 \
  -Dheaders=true \
  -Dentrypoint-patching=disabled \
  -Dprefix=/usr
