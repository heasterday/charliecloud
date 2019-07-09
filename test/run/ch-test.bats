load ../common

unset_vars () {
    # Save the original CH_TEST environment variables.
    [[ -n $tardir ]] || tardir=$CH_TEST_TARDIR
    [[ -n $imgdir ]] || imgdir=$CH_TEST_IMGDIR
    [[ -n $scope ]] || scope=$CH_TEST_SCOPE
    [[ -n $permdirs ]] || permdirs=$CH_TEST_PERMDIRS
    unset CH_TEST_TARDIR
    unset CH_TEST_IMGDIR
    unset CH_TEST_SCOPE
    unset CH_TEST_PERMDIRS
}

set_vars () {
    export CH_TEST_TARDIR=$tardir
    export CH_TEST_IMGDIR=$imgdir
    export CH_TEST_SCOPE=$scope
    export CH_TEST_PERMDIRS=$permdirs
}

test () {

    # Ensure the interactions between ch-test and set CH_TEST_* environment
    # variables function as intended, i.e., ch-test always prioritizes a set
    # CH_TEST_* variable over a value specified with an argument, e.g., --scope,
    # --prefix, etc.

    testdir="${ch_bin/\/bin}/test"

    # Environment variables set, no arguments
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           quick
CH_TEST_TARDIR          /tmp/tar
CH_TEST_IMGDIR          /tmp/img
CH_TEST_PERMDIRS        /tmp /var/tmp
EOF
)
    unset_vars
    export CH_TEST_TARDIR=/tmp/tar
    export CH_TEST_IMGDIR=/tmp/img
    export CH_TEST_SCOPE=quick
    export CH_TEST_PERMDIRS='/tmp /var/tmp'
    ch-test "$1" --summary > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # No environment variables, no arguments
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    unset_vars
    ch-test "$1" --summary > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out


    # Environment variables set, --prefix argument
    expected_out=$(cat << EOF
prefix: warning: CH_TEST_TARDIR set and will be used
prefix: warning: CH_TEST_IMGDIR set and will be used
prefix: warning: CH_TEST_PERMDIRS set and will be used
prefix: warning: CH_TEST_SCOPE set and will be used

running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    export CH_TEST_TARDIR=/var/tmp/tar
    export CH_TEST_IMGDIR=/var/tmp/dir
    export CH_TEST_SCOPE=standard
    export CH_TEST_PERMDIRS='/var/tmp /tmp'
    ch-test --prefix=/tmp/foo --summary "$1"  > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out
    ch-test -p /tmp/foo --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out


    # No environment variables, --prefix argument
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /foo/bar/dir
CH_TEST_PERMDIRS        /foo/bar
EOF
)
    unset_vars
    ch-test --prefix=/foo/bar --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    ch-test -p /foo/bar --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out


    # Environment variable set, --scope argument
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           quick
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /foo/bar/dir
CH_TEST_PERMDIRS        skip
EOF
)
    export CH_TEST_TARDIR=/foo/bar/tar
    export CH_TEST_IMGDIR=/foo/bar/dir
    export CH_TEST_SCOPE=quick
    export CH_TEST_PERMDIRS=skip
    ch-test --scope=full --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    ch-test -s full --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # No environment variables, --scope argument
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           full
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    unset_vars
    ch-test --scope=full --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    ch-test -s full --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # Environment variables set, --scope and --prefix args
    expected_out=$(cat << EOF
prefix: warning: CH_TEST_TARDIR set and will be used
prefix: warning: CH_TEST_IMGDIR set and will be used
prefix: warning: CH_TEST_PERMDIRS set and will be used
prefix: warning: CH_TEST_SCOPE set and will be used

running tests from:     $testdir
CH_TEST_SCOPE           quick
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    export CH_TEST_TARDIR=/var/tmp/tar
    export CH_TEST_IMGDIR=/var/tmp/dir
    export CH_TEST_SCOPE=quick
    export CH_TEST_PERMDIRS='/var/tmp /tmp'
    ch-test --scope=full --prefix=/foo/bar --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    ch-test -s full -p /foo/bar --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # No environment variables, --scope and --prefix args
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           full
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /foo/bar/dir
CH_TEST_PERMDIRS        /foo/bar
EOF
)
    unset_vars
    ch-test --scope=full --prefix=/foo/bar --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    ch-test -s full -p /foo/bar --summary "$1" > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # Partial environment, no args
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    unset_vars
    export CH_TEST_TARDIR=/foo/bar/tar
    ch-test "$1" --summary > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # Partial environment, --scope argument
    expected_out=$(cat << EOF

running tests from:     $testdir
CH_TEST_SCOPE           full
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    unset_vars
    export CH_TEST_TARDIR=/foo/bar/tar
    ch-test "$1" --scope=full --summary > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # Partial environment, --prefix argument
    expected_out=$(cat << EOF
prefix: warning: CH_TEST_TARDIR set and will be used

running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /tmp/dir
CH_TEST_PERMDIRS        /tmp
EOF
)
    unset_vars
    export CH_TEST_TARDIR=/foo/bar/tar
    ch-test "$1" --prefix=/tmp --summary > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # Partial environment, --prefix and --scope args
    expected_out=$(cat << EOF
prefix: warning: CH_TEST_IMGDIR set and will be used

running tests from:     $testdir
CH_TEST_SCOPE           quick
CH_TEST_TARDIR          /tmp/tar
CH_TEST_IMGDIR          /fizz/buzz/img
CH_TEST_PERMDIRS        /tmp
EOF
)
    unset_vars
    export CH_TEST_IMGDIR=/fizz/buzz/img
    ch-test "$1" -p /tmp -s quick --summary > output.out
    echo "$expected_out" > expected.out
    diff -u output.out expected.out
    rm output.out expected.out

    # Reset CH_TEST environment variables
    set_vars
}

@test 'ch-test build' {
    test build
}

@test 'ch-test run' {
    test run
}

@test 'ch-test errors' {
    # No arguments
    run ch-test
    echo "$output"
    [[ $output = *'Usage:'* ]]
    [[ $status -eq 1 ]]

    # No phase specified
    run ch-test --prefix=foo
    echo "$output"
    [[ $output = *'test phase not specified'* ]]
    [[ $status -eq 1 ]]
    run ch-test -p foo -s full
    echo "$output"
    [[ $output = *'test phase not specified'* ]]
    [[ $status -eq 1 ]]

    # Multiple phases specified
    run ch-test build run
    echo "$output"
    [[ $output = *'test phase may only be assigned once'* ]]
    [[ $status -eq 1 ]]
    run ch-test build all
    echo "$output"
    [[ $output = *'test phase may only be assigned once'* ]]
    [[ $status -eq 1 ]]
    run ch-test all run
    echo "$output"
    [[ $output = *'test phase may only be assigned once'* ]]
    [[ $status -eq 1 ]]
    run ch-test build --prefix=/tmp run
    echo "$output"
    [[ $output = *'test phase may only be assigned once'* ]]
    [[ $status -eq 1 ]]

    # Malformed arugments
    run ch-test --prefix foo build
    echo "$output"
    [[ $status -eq 1 ]]
    run ch-test --scope foo build
    echo "$output"
    [[ $status -eq 1 ]]
}

@test 'ch-test clean' {
    run ch-test clean --summary
    echo "$output"
    [[ $output = *"clean targets: $CH_TEST_TARDIR, $CH_TEST_IMGDIR"* ]]
}
