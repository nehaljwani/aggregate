#!/bin/bash

set -x

export EXTRA_OPTS=""

if [[ $(uname) == MINGW* ]]; then
  if [[ ${ARCH} == 32 ]]; then
    HOST_BUILD="--host=i686-w64-mingw32 --build=i686-w64-mingw32"
	echo "ac_cv_search_recv=-lws2_32" > config.site
	export CONFIG_SITE=${PWD}/config.site
  else
    HOST_BUILD="--host=x86_64-w64-mingw32 --build=x86_64-w64-mingw32"
  fi
  PREFIX="${PREFIX}"/Library/mingw-w64
  export PKG_CONFIG_PATH="${PREFIX}"/lib/pkgconfig
else
  export HOST_BUILD="--host=${HOST}"
  export EXTRA_OPTS="--enable-plugins"
fi

# Fix shebangs
for f in test/compare_sam.pl; do
    sed -i.bak -e 's|^#!/usr/bin/perl -w|#!/usr/bin/env perl|' "$f"
    rm -f "$f.bak"
done
set -e
autoreconf -vfi
./configure \
    --prefix="${PREFIX}" \
    ${HOST_BUILD} \
    --enable-libcurl \
    --enable-s3 \
    --enable-gcs \
	${EXTRA_OPTS} \
    CFLAGS="$CFLAGS -I${PREFIX}/include" \
    LDFLAGS="$LDFLAGS -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"


make -j${CPU_COUNT} ${VERBOSE_AT}

make test

make install prefix=$PREFIX
