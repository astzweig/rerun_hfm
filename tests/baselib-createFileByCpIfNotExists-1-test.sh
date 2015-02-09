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

it_stops_with_source_being_empty_or_invalid() {
  local RETV DEST_FN="${MODULE}-notexistingfile1-$$.txt";
  local SRC_FN="${MODULE}-notexistingfile2-$$.txt";
  test ! -f "${DEST_FN}";
  test ! -f "${SRC_FN}";

  RETV="$(createFileByCpIfNotExists ${DEST_FN} \"\" && echo $? || echo $?)";
  test ${RETV} -eq 20;
  test ! -f "${DEST_FN}";
  test ! -f "${SRC_FN}";

  RETV="$(createFileByCpIfNotExists ${DEST_FN} ${SRC_FN} && echo $? || echo $?)";
  test ${RETV} -eq 20;
  test ! -f "${DEST_FN}";
  test ! -f "${SRC_FN}";
}

it_stops_with_user_disallowing_source_creation() {
  local RETV DEST_FN="${MODULE}-notexistingfile1-$$.txt";
  local SRC_FN="${MODULE}-existingfile1-$$.txt";
  [ ! -f "${SRC_FN}" ] && touch "${SRC_FN}";
  trap "rm -f ${SRC_FN}" EXIT INT;
  test ! -f "${DEST_FN}";
  test -f "${SRC_FN}";

  RETV="$(createFileByCpIfNotExists ${DEST_FN} ${SRC_FN} <<< "no" && echo $? || echo $?)";
  test ${RETV} -eq 30;
  test ! -f "${DEST_FN}";
  test -f "${SRC_FN}";
}

it_works_with_source_already_existing() {
  local RETV DEST_FN="${MODULE}-existingfile1-$$.txt";
  local SRC_FN="${MODULE}-notexistingfile1-$$.txt";
  [ ! -f "${DEST_FN}" ] && touch "${DEST_FN}";
  trap "rm -f ${DEST_FN}" EXIT INT;

  test -f "${DEST_FN}";
  test ! -f "${SRC_FN}";
  RETV="$(createFileByCpIfNotExists ${DEST_FN} ${SRC_FN} && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test -f "${DEST_FN}";
  test ! -f "${SRC_FN}";
}

it_works_with_user_allowing_source_creation() {
  local RETV DEST_FN="${MODULE}-notexistingfile1-$$.txt";
  local SRC_FN="${MODULE}-existingfile12-$$.txt" TESTSTR="Hello-World-$$";
  [ ! -f "${SRC_FN}" ] && echo "${TESTSTR}" >> "${SRC_FN}";
  trap "{ rm -f ${SRC_FN}; rm -f ${DEST_FN}; }" EXIT INT;
  test ! -f "${DEST_FN}";
  test -f "${SRC_FN}";

  RETV="$(createFileByCpIfNotExists ${DEST_FN} ${SRC_FN} <<< "yes" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test -f "${DEST_FN}";
  test "$(cat ${DEST_FN})" == "${TESTSTR}";
  test -f "${SRC_FN}";
}