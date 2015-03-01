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
LIB_PATH="${RERUN_MODULES}/${MODULE}/lib/add-rm-functions.sh";
if [ ! -f ${LIB_PATH} ]; then
    exit;
fi

source ${LIB_PATH};

# The Plan
# --------

describe "addlib - addHostToFileIfNotExists"

it_stops_with_no_arguments() {
  local RETV;
  RETV="$(addHostToFileIfNotExists && echo $? || echo $?)";
  test ${RETV} -eq 30;
}

it_stops_with_filePath_not_existing() {
  local RETV DEST_FN="${MODULE}-notexistingfile1-$$.txt";
  test ! -f ${DEST_FN};
  trap "rm -f ${DEST_FN}" EXIT INT;

  RETV="$(addHostToFileIfNotExists "${DEST_FN}" && echo $? || echo $?)";
  test ! -f ${DEST_FN};
  test ${RETV} -eq 30;
}

it_stops_with_already_existing_host() {
  local RETV DEST_FN="./${MODULE}-existingfile1-$$.txt";
  local HOST="www.example.dev example.dev" IP="127.0.0.1";
  local TESTHOST="example.dev";
  local RESULTSTR="$(echo -e ${IP}\\$'t'${HOST})";
  [ ! -f "${DEST_FN}" ] && echo "${RESULTSTR}" >> "${DEST_FN}";
  trap "rm -f ${DEST_FN}" EXIT INT;

  test "$(cat ${DEST_FN})" == "${RESULTSTR}";
  RETV="$(addHostToFileIfNotExists "${DEST_FN}" "${TESTHOST}" "${IP}" && echo $? || echo $?)";
  test ${RETV} -eq 40;
  test "$(cat ${DEST_FN})" == "${RESULTSTR}";
}

it_works_with_existing_file() {
  local RETV DEST_FN="./${MODULE}-existingfile1-$$.txt";
  local HOST="www.example.dev example.dev" IP="127.0.0.1";
  local RESULTSTR="$(echo -e ${IP}\\$'t'${HOST})";
  [ ! -f "${DEST_FN}" ] && touch "${DEST_FN}";
  trap "rm -f ${DEST_FN}" EXIT INT;

  RETV="$(addHostToFileIfNotExists "${DEST_FN}" "${HOST}" "${IP}" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test "$(cat ${DEST_FN})" == "${RESULTSTR}";
}