#!/usr/bin/env roundup
#
# Baselib test
#/ usage: rerun stubbs:test -m MODULE -p baselib
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# Include baselib file
# -----------------
MODULE="$(basename $(cd ..; pwd))";
BASELIB_PATH="${RERUN_MODULES}/${MODULE}/lib/baselib.sh";
if [ ! -f ${BASELIB_PATH} ]; then
    exit;
fi

source ${BASELIB_PATH};

# The Plan
# --------

describe "baselib - createFileByCpIfNotExists"

it_stops_with_no_arguments() {
  local RETV;
  RETV="$(createFileByCpIfNotExists && echo $? || echo $?)";
  test ${RETV} -eq 10;
}

it_stops_with_source_path_being_empty() {
  local RETV DEST_FN="${MODULE}-somefile-$$.txt";
  RETV="$(createFileByCpIfNotExists "${DEST_FN}" && echo $? || echo $?)";
  test ${RETV} -eq 20;
  test ! -f "${DEST_FN}";
}