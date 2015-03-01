#!/usr/bin/env roundup
#
# addlib test
#/ usage: rerun stubbs:test -m MODULE
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# Include addlib file
# -----------------
MODULE="$(basename $(cd ..; pwd))";
LIB_PATH="${RERUN_MODULES}/${MODULE}/lib/add-functions.sh";
if [ ! -f ${LIB_PATH} ]; then
    exit;
fi

source ${LIB_PATH};

# The Plan
# --------

describe "addlib - checkHostAndIPAddress"

it_stops_with_no_arguments() {
  local RETV;
  RETV="$(checkHostAndIPAddress && echo $? || echo $?)";
  test ${RETV} -eq 10;
}

it_stops_with_invalid_host() {
  local RETV;
  RETV="$(checkHostAndIPAddress "invalidhost" "127.0.0.1" && echo $? || echo $?)";
  test ${RETV} -eq 10;
}

it_stops_with_invalid_ip() {
  local RETV;
  RETV="$(checkHostAndIPAddress "validhost.de" "127" && echo $? || echo $?)";
  test ${RETV} -eq 20;
}

it_runs_with_multiple_host_and_valid_ip() {
  local RETV;
  RETV="$(checkHostAndIPAddress "www.validhost.de validhost.de" "127.0.0.1" && echo $? || echo $?)";
  test ${RETV} -eq 0;
}

it_runs_with_valid_host_and_ip() {
  local RETV;
  RETV="$(checkHostAndIPAddress "validhost.de" "127.0.0.1" && echo $? || echo $?)";
  test ${RETV} -eq 0;
}