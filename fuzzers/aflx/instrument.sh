#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env MAGMA: path to Magma support files
# - env OUT: path to directory where artifacts are stored
# - env CFLAGS and CXXFLAGS must be set to link against Magma instrumentation
##

export CC="$FUZZER/repo/afl-clang-fast"
export CXX="$FUZZER/repo/afl-clang-fast++"
export AS="$FUZZER/repo/afl-as"

export LIBS="$LIBS -l:afl_driver.o -lstdc++"

"$MAGMA/build.sh"
#"$TARGET/build.sh"
export IS_AFLX=1
for (( i=1; i<=FUZZER_NUM; i++ )); do
    # Set the environment variable for the current iteration
    export FUZZER_ID=$i

    # Call the build script
    echo "Running build with FUZZER_ID set to $FUZZER_ID"
    "$TARGET/build.sh"
    echo "Funished build with FUZZER_ID set to $FUZZER_ID"


    # Optionally, you can unset the environment variable if needed
    # unset MY_ENV_VAR
done

# NOTE: We pass $OUT directly to the target build.sh script, since the artifact
#       itself is the fuzz target. In the case of Angora, we might need to
#       replace $OUT by $OUT/fast and $OUT/track, for instance.
