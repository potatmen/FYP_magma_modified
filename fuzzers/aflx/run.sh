#!/bin/bash

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
# - env PROGRAM: name of program to run (should be found in $OUT)
# - env ARGS: extra arguments to pass to the program
# - env FUZZARGS: extra arguments to pass to the fuzzer
##

echo "Here"
ls "$OUT/"
mkdir -p "$SHARED/findings"

export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1
#"$FUZZER/repo/afl-fuzz" -m 100M -i "$TARGET/corpus/$PROGRAM" -o "$SHARED/findings" \
#    $FUZZARGS -- "$OUT/$PROGRAM" $ARGS 2>&1
for i in $(seq 1 $FUZZER_NUM); do
    if [ $i -eq 1 ]; then
        "$FUZZER/repo/afl-fuzz" -m 300M -i "$TARGET/corpus/$PROGRAM" -o "$SHARED/findings" \
            -M fuzzer1 -- "$OUT/fuzzer_${FUZZER_ID}/${PROGRAM}" $ARGS 2>&1 &
    else
         "$FUZZER/repo/afl-fuzz" -m 300M -i "$TARGET/corpus/$PROGRAM" -o "$SHARED/findings" \
            -S fuzzer$i -- "$OUT/fuzzer_${FUZZER_ID}/${PROGRAM}" $ARGS 2>&1 &
    fi
done

wait

echo "Done starting $NUM_INSTANCES instances"