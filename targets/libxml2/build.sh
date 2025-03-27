#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env CC, CXX, FLAGS, LIBS, etc...
##

if [ ! -d "$TARGET/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

cd "$TARGET/repo"
./autogen.sh \
	--with-http=no \
	--with-python=no \
	--with-lzma=yes \
	--with-threads=no \
	--disable-shared
make -j$(nproc) clean
make -j$(nproc) all


if [ -z "$IS_AFLX" ]; then
    cp xmllint "$OUT/"

    for fuzzer in libxml2_xml_read_memory_fuzzer libxml2_xml_reader_for_file_fuzzer; do
      $CXX $CXXFLAGS -std=c++11 -Iinclude/ -I"$TARGET/src/" \
          "$TARGET/src/$fuzzer.cc" -o "$OUT/$fuzzer" \
          .libs/libxml2.a $LDFLAGS $LIBS -lz -llzma
    done
else
    NEW_DIR="$OUT/fuzzer_$FUZZER_ID"
    mkdir $NEW_DIR
    echo "Dir name is $NEW_DIR"
    cp xmllint "$NEW_DIR/"

    for fuzzer in libxml2_xml_read_memory_fuzzer libxml2_xml_reader_for_file_fuzzer; do
      $CXX $CXXFLAGS -std=c++11 -Iinclude/ -I"$TARGET/src/" \
          "$TARGET/src/$fuzzer.cc" -o "$NEW_DIR/$fuzzer" \
          .libs/libxml2.a $LDFLAGS $LIBS -lz -llzma
    done
fi
