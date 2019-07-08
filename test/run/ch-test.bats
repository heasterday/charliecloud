load ../common

unset_vars () {
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
    testdir="${ch_bin#%/bin}/test"
    # Environment variables already set
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
    run ch-test $1 --summary
    echo "$output"
    diff -u "$output" "$expected_out"

    # No environment variables
    expected_out=$(cat << EOF
running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    run ch-test $1 --summary
    echo "$output"
    diff -u "$output" "$expected_out"

    # Environment variables with --prefix
    expected_out=$(cat << EOF
running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    run ch-test --prefix=/tmp/foo --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"
    run ch-test -p /tmp/foo --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"

    # No environment with --prefix
    expected_out=$(cat << EOF
running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /foo/bar/dir
CH_TEST_PERMDIRS        /foo/bar
EOF
)
    unset-vars
    run ch-test --prefix=/foo/bar --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"
    run ch-test -p /tmp/foo --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"

    # Environment with --scope
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
    run ch-test --scope=full --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"
    run ch-test -s full --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"


    # No environment with --scope
    expected_out=$(cat << EOF
running tests from:     $testdir
CH_TEST_SCOPE           full
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    unset_vars
    run ch-test --scope=full --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"
    run ch-test -s full --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"

    # Environment with --scope and --prefix
    expected_out=$(cat << EOF
running tests from:     $testdir
CH_TEST_SCOPE           standard
CH_TEST_TARDIR          /var/tmp/tar
CH_TEST_IMGDIR          /var/tmp/dir
CH_TEST_PERMDIRS        /var/tmp /tmp
EOF
)
    export CH_TEST_TARDIR=/var/tmp/tar
    export CH_TEST_IMGDIR=/var/tmp/dir
    export CH_TEST_SCOPE=quick
    export CH_TEST_PERMDIRS='/var/tmp /tmp'
    run ch-test --scope=full --prefix=/foo/bar --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"
    run ch-test -s full --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"

    # No environment with --scope and --prefix
    expected_out=$(cat << EOF
running tests from:     /$testdir
CH_TEST_SCOPE           full
CH_TEST_TARDIR          /foo/bar/tar
CH_TEST_IMGDIR          /foo/bar/dir
CH_TEST_PERMDIRS        /foo/bar
EOF
)
    run ch-test --scope=full --prefix=/foo/bar --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"
    run ch-test -s full -p /foo/bar --summary $1
    echo "$output"
    diff -u "$output" "$expected_out"
}

@test 'ch-test build' {
    test build
}

@test 'ch-test run' {
    test run
}

@test 'ch-test errors' {
    # Specify multiple phases
    run ch-test build run
    [[ ! $status = 0 ]]
    run ch-test build all
    [[ ! $status = 0 ]]
    run ch-test all run
    [[ ! $status = 0 ]]
    run ch-test build --prefix=/tmp run
    [[ ! $status = 0 ]]
}

@test 'ch-test clean' {
}
