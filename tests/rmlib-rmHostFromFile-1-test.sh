#!/usr/bin/env roundup
#
# rmlib test
#/ usage: rerun stubbs:test -m MODULE
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# Include rmlib file
# -----------------
MODULE="$(basename $(cd ..; pwd))";
LIB_PATH="${RERUN_MODULES}/${MODULE}/lib/add-rm-functions.sh";
if [ ! -f ${LIB_PATH} ]; then
    exit;
fi

source ${LIB_PATH};

# The Plan
# --------

describe "rmlib - rmHostFromFile"

it_stops_with_no_arguments() {
  local RETV;
  RETV="$(rmHostFromFile && echo $? || echo $?)";
  test ${RETV} -eq 10;
}

it_stops_with_filePath_not_existing() {
  local RETV DEST_FN="${MODULE}-notexistingfile1-$$.txt";
  test ! -f ${DEST_FN};
  trap "rm -f ${DEST_FN}" EXIT INT;

  RETV="$(rmHostFromFile "${DEST_FN}" && echo $? || echo $?)";
  test ! -f ${DEST_FN};
  test ${RETV} -eq 10;
}

it_stops_with_existing_host() {
  local RETV DEST_FN="./${MODULE}-existingfile1-$$.txt";
  local HOST="www.example.dev example.dev" IP="127.0.0.1";
  local TESTHOST="example.dev";
  local RESULTSTR="$(echo -e ${IP}\\$'t'${HOST})";
  local ADDSTR="hallo";
  [ ! -f "${DEST_FN}" ] && echo "${RESULTSTR}"$'\n'"${ADDSTR}" >> "${DEST_FN}";
  trap "rm -f ${DEST_FN}" EXIT INT;

  test "$(cat ${DEST_FN})" == "${RESULTSTR}"$'\n'"${ADDSTR}";
  RETV="$(rmHostFromFile "${DEST_FN}" "${TESTHOST}" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test "$(cat ${DEST_FN})" == "${ADDSTR}";
}

it_works_with_nonexisting_host() {
  local RETV DEST_FN="./${MODULE}-existingfile1-$$.txt";
  local HOST="www.example.dev example.dev" IP="127.0.0.1";
  local TESTHOST="notexistinghost.dev";
  local RESULTSTR="$(echo -e ${IP}\\$'t'${HOST})";
  local ADDSTR="hallo";
  [ ! -f "${DEST_FN}" ] && echo "${RESULTSTR}"$'\n'"${ADDSTR}" >> "${DEST_FN}";
  trap "rm -f ${DEST_FN}" EXIT INT;

  test "$(cat ${DEST_FN})" == "${RESULTSTR}"$'\n'"${ADDSTR}";
  RETV="$(rmHostFromFile "${DEST_FN}" "${TESTHOST}" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test "$(cat ${DEST_FN})" == "${RESULTSTR}"$'\n'"${ADDSTR}";
}