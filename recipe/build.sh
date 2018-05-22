#!/bin/bash

# ++awful .. broken configure script here, it does not look in include/openssl
cp -f ${PREFIX}/include/openssl/des.h ${PREFIX}/include

if [[ ${target_platform} == osx-64 ]]; then
  DISABLE_MACOS_FRAMEWORK=--disable-macos-framework
fi

if [[ ${target_platform} =~ .*ppc.* ]]; then
  # We should probably run autoreconf here instead, but I am tired of this software.
  BUILD="--build=${HOST}"
fi

# --disable-dependency-tracking works around:
# https://forums.gentoo.org/viewtopic-t-366917-start-0.html
./configure --prefix=${PREFIX}                    \
            --host=${HOST}                        \
            ${BUILD}                              \
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
if [[ ${target_platform} == osx-64 ]]; then
  ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/libsasl2.dylib ${PREFIX}/lib/libsasl2.dylib
  ${INSTALL_NAME_TOOL:-install_name_tool} -change /libsasl2.dylib @rpath/libsasl2.dylib ${PREFIX}/sbin/pluginviewer
  ${INSTALL_NAME_TOOL:-install_name_tool} -change /libsasl2.dylib ${PREFIX}/lib/libsasl2.dylib ${PREFIX}/sbin/saslpasswd2
  ${INSTALL_NAME_TOOL:-install_name_tool} -change /libsasl2.dylib ${PREFIX}/lib/libsasl2.dylib ${PREFIX}/sbin/sasldblistusers2
fi
