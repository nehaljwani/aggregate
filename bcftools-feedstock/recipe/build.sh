#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [[ $(uname) == MINGW* ]]; then
  if [[ ${ARCH} == 32 ]]; then
    HOST_BUILD="--host=i686-w64-mingw32 --build=i686-w64-mingw32"
  else
    HOST_BUILD="--host=x86_64-w64-mingw32 --build=x86_64-w64-mingw32"
  fi
  PREFIX="${PREFIX}"/Library/mingw-w64
  export PKG_CONFIG_PATH="${PREFIX}"/lib/pkgconfig
else
  export HOST_BUILD="--host=${HOST}"
fi

autoreconf -vfi

./configure \
    --prefix=$PREFIX \
    ${HOST_BUILD} \
    --with-htslib=$PREFIX \
    CFLAGS="-I$PREFIX/include" \
    LDFLAGS="$LDFLAGS -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

make -j${CPU_COUNT} ${VERBOSE_AT}

make test

make install prefix=$PREFIX
