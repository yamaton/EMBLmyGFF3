#!/usr/bin/env bash

## SETUP VIRTUAL ENVIRONMENT FOR TESTING
if [ "x$TRAVIS" != "x" ]; then
    if [ -d t/venv ]; then
        rm -rf t/venv
    fi

    virtualenv t/venv
    source t/venv/bin/activate
    trap 'deactivate' EXIT
fi

python setup.py install


## RUN TESTS
cd t

sed -Ei -e 's/^(DT   )[0-9]{2}-[A-Za-z]{3}-[0-9]{4}/\1'"$(date +%d-%^b-%Y)"'/' \
        -e 's/^(RL   Submitted \()[0-9]{2}-[A-Za-z]{3}-[0-9]{4}/\1'"$(date +%d-%^b-%Y)"'/' \
       *.embl

SUCCESS=0
FAIL=0

for NAME in augustus maker prokka; do
    RESULT_FILE="EMBLmyGFF3-${NAME}-example.embl"
    EXPECTED_FILE="EMBLmyGFF3-${NAME}-test.embl"
    [ -f "$RESULT_FILE" ] && rm $RESULT_FILE
    ../examples/${NAME}_example.py

    if diff -q "$RESULT_FILE" "$EXPECTED_FILE"; then
        SUCCESS=$(( $SUCCESS + 1 ))
    else
        diff "$RESULT_FILE" "$EXPECTED_FILE"
        FAIL=$(( $FAIL + 1 ))
    fi
done

if [ $FAIL -eq 0 ]; then
    echo "All tests successfull"
    exit 0
fi

echo "Failed $FAIL out of 3 tests"
exit 1
