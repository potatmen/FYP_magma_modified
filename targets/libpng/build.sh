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

# build the libpng library
cd "$TARGET/repo"
autoreconf -f -i
./configure --with-libpng-prefix=MAGMA_ --disable-shared
make -j$(nproc) clean
make -j$(nproc) libpng16.la

if [ -z "$IS_AFLX" ]; then
    cp .libs/libpng16.a "$OUT/"

    # build libpng_read_fuzzer. 
    $CXX $CXXFLAGS -std=c++11 -I. \
        contrib/oss-fuzz/libpng_read_fuzzer.cc \
        -o $OUT/libpng_read_fuzzer \
        $LDFLAGS .libs/libpng16.a $LIBS -lz
else
    NEW_DIR="$OUT/fuzzer_$FUZZER_ID"
    mkdir $NEW_DIR
    echo "Dir name is $NEW_DIR"
    cp .libs/libpng16.a "$NEW_DIR/"

    # build libpng_read_fuzzer. 
    $CXX $CXXFLAGS -std=c++11 -I. \
        contrib/oss-fuzz/libpng_read_fuzzer.cc \
        -o $NEW_DIR/libpng_read_fuzzer \
        $LDFLAGS .libs/libpng16.a $LIBS -lz
fi
