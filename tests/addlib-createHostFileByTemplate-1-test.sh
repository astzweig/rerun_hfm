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

describe "addlib - createHostFileByTemplate"

it_stops_with_no_arguments() {
  local RETV;
  RETV="$(createHostFileByTemplate && echo $? || echo $?)";
  test ${RETV} -eq 10;
}

it_stops_with_destpath_existing_already() {
  local RETV DEST_FN="${MODULE}-existingfile1-$$.txt";
  [ ! -f "${DEST_FN}" ] && touch "${DEST_FN}";
  trap "rm -f ${DEST_FN}" EXIT INT;

  RETV="$(createHostFileByTemplate "${DEST_FN}" && echo $? || echo $?)";
  test ${RETV} -eq 20;
}

it_stops_with_wrong_parentdir_of_destpath() {
  local RETV DEST_FN="./nonexistentdir/${MODULE}-nonexistingfile1-$$.txt";
  trap "rm -f ${DEST_FN}" EXIT INT;

  test ! -f ${DEST_FN};
  RETV="$(createHostFileByTemplate "${DEST_FN}" && echo $? || echo $?)";
  test ${RETV} -eq 30;
}

it_stops_with_user_disallowing_file_creation() {
  local RETV DEST_FN="./${MODULE}-nonexistingfile1-$$.txt";
  trap "rm -f ${DEST_FN}" EXIT INT;

  test ! -f ${DEST_FN};
  RETV="$(createHostFileByTemplate "${DEST_FN}" <<< "no" && echo $? || echo $?)";
  test ${RETV} -eq 40;
}

it_works_without_template_args() {
  local RETV DEST_FN="./${MODULE}-nonexistingfile1-$$.txt";
  trap "rm -f ${DEST_FN}" EXIT INT;

  test ! -f ${DEST_FN};
  RETV="$(createHostFileByTemplate "${DEST_FN}" <<< "yes" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test -f ${DEST_FN};
}

it_works_with_user_aborting_template_selection() {
  local RETV TMPD="$(pwd)/.${MODULE}1.$$";
  local OTHER_FN="${TMPD}/existingfile1-$$.txt";
  local DEST_FN="${TMPD}/nonexistingfile1-$$.txt";
  local TESTSTR="Hall$$";
  [ ! -d "${TMPD}" ] && mkdir ${TMPD};
  [ ! -f "${OTHER_FN}" ] && echo "${TESTSTR}" >> "${OTHER_FN}";
  trap "rm -rf \"${TMPD}\"" EXIT INT;

  test ! -f "${DEST_FN}";
  RETV="$(createHostFileByTemplate "${DEST_FN}" ${TMPD}/* <<< "yes"$'\n'"2" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test -f "${DEST_FN}";
  test "$(cat ${DEST_FN})" != "${TESTSTR}";
}

it_works_with_user_selecting_template() {
  local RETV TMPD="$(pwd)/.${MODULE}1.$$";
  local OTHER_FN="${TMPD}/existingfile1-$$.txt";
  local DEST_FN="${TMPD}/nonexistingfile1-$$.txt";
  local TESTSTR="Hall$$";
  [ ! -d "${TMPD}" ] && mkdir ${TMPD};
  [ ! -f "${OTHER_FN}" ] && echo "${TESTSTR}" >> "${OTHER_FN}";
  trap "rm -rf \"${TMPD}\"" EXIT INT;

  test ! -f "${DEST_FN}";
  RETV="$(createHostFileByTemplate "${DEST_FN}" ${TMPD}/* <<< "yes"$'\n'"1" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test -f "${DEST_FN}";
  test "$(cat ${DEST_FN})" == "${TESTSTR}";
}