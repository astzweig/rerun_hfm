#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m hfm -p add [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "add"

# ------------------------------
it_is_already_tested_by_addlib_tests() {
    exit 0
}
# ------------------------------

