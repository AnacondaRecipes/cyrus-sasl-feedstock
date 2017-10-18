#!/bin/bash

# ++awful .. broken configure script here, it does not look in include/openssl
cp -f ${PREFIX}/include/openssl/des.h ${PREFIX}/include

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ ${HOST} =~ .*darwin.* ]]; then
  DISABLE_MACOS_FRAMEWORK=--disable-macos-framework
fi

# --disable-dependency-tracking works around:
# https://forums.gentoo.org/viewtopic-t-366917-start-0.html
./configure --prefix=${PREFIX}                    \
            --host=${HOST}                        \
            --enable-digest                       \
            --with-des=${PREFIX}                  \
            --with-plugindir=${PREFIX}/lib/sasl2  \
            --with-configdir=${PREFIX}/etc/sasl2  \
            --with-openssl=${PREFIX}              \
            --disable-dependency-tracking         \
            ${DISABLE_MACOS_FRAMEWORK} || { cat config.log; exit 1; }
cat config.log
# Parallel builds fail frequently.
make -j1 ${VERBOSE_AT}
make install

# awful--
rm -f ${PREFIX}/include/des.h

# ++awful
if [[ ${HOST} =~ .*darwin.* ]]; then
  ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/libsasl2.dylib ${PREFIX}/lib/libsasl2.dylib
fi
