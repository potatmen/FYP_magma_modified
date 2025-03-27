#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env CC, CXX, FLAGS, LIBS, etc...
##

echo "Triggered"

if [ ! -d "$TARGET/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

cd "$TARGET/repo"
./autogen.sh
./configure --disable-shared --enable-ossfuzzers
make -j$(nproc) clean
make -j$(nproc) ossfuzz/sndfile_fuzzer

#cp -v ossfuzz/sndfile_fuzzer $OUT/
if [ -z "$IS_AFLX" ]; then
    cp -v ossfuzz/sndfile_fuzzer $OUT/
else
    NEW_DIR="$OUT/fuzzer_$FUZZER_ID"
    mkdir $NEW_DIR
    echo "Dir name is $NEW_DIR"
    cp -v ossfuzz/sndfile_fuzzer $NEW_DIR/
fi

