Synopsis
========

::

  $ ch-test [ARG ...] [PHASE]

Description
===========

Run the Charliecloud test suite.

For details about the test suite, see:
https://hpc.github.io/charliecloud/test.html

Available phases are the following. Each phase requires successful completion
of the prior phase at the same scope.

  :code:`build`
    Test that images build correctly.

  :code:`run`
    Test that images run correctly. If :code:`sudo` privileges are
    available, also test file system permission enforcement.

  :code:`examples`
    Test that example applications work correctly.

  :code:`all`
    Test all three phases in the order above. (Default.)

Clean-up phase:

  :code:`clean`
    Delete all test data, including in builder storage.

Other arguments:

  :code:`-p`, :code:`--prefix=DIR`
    Directory containing image files/directories and other test fixtures if
    the relevant environment variables are not set. Default: :code:`/var/tmp`.

  :code:`-s`, :code:`--scope=[quick|standard|full]`
    Run tests with given scope. Default: :code:`$CH_TEST_SCOPE` if set,
    otherwise :code:`standard`.

  :code:`--summary`
    Print the test suite variables or clearn targets without executing phase.

Storage
=======

The test suite requires a few tens of GB of storage for test fixtures:

* Builder storage (e.g., layer cache). This goes wherever the builder puts it.

* Image tarballs: :code:`{--prefix}/tar` or :code:`$CH_TEST_TARDIR` if set.

* Image directories: :code:`{--prefix}/dir` or :code:`$CH_TEST_IMGDIR` if set.

* File permission enforcement fixtures: :code:`{--prefix}/perms_test` or
  :code:`$CH_TEST_PERMDIRS` if set.

All of these directories are created if they don't exist.

Exit status
===========

Zero if the tests passed; non-zero if they failed. For phase :code:`clean`,
zero if everything was deleted correctly, non-zero otherwise.

Example
=======

::

  $ ch-test build
  running tests from: /usr/local/src/charliecloud/test
  CH_TEST_SCOPE:      standard
  CH_TEST_TARDIR:     /var/tmp/tar
  CH_TEST_IMGDIR:     /var/tmp/img
  CH_TEST_PERMDIRS:   /var/tmp tmp

  bats build.bats build_auto.bats build_post.bats
  ✓ create tarball directory if needed
  ✓ documentations build
  ✓ version number seems sane
  ✓ executables seem sane
  [...]
  58 tests, 0 failures, 3 skipped
