#!/bin/bash
# Shell functions for the add command of hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/add-functions.sh
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#


# - - -
# Functions declared here.
# - - -
function checkHostAndIPAddress {
  # Usage: checkHostAndIPAddress <host> <ipaddress>
  #
  # @args:
  #   str host:      One host or a list of hosts seperated by space
  #   str ipaddress: The IP address where the host(s) shall be mapped to
  #
  # @version: 1.0
  # @see: rerun_log
  # @examples:
  #   checkHostAndIPAddress "newhost.dev www.newhost.dev" 127.0.0.1
  # @errors:
  #   10: Invalid host given
  #   20: Invalid IP address given
  #
  local DOMAINREGEX="^[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]+\.[a-zA-Z]{2,4}$";
  local IPREGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$";
  rerun_log debug "Entering checkHostAndIPAddress function with $# arguments";
  if [[ ! "$1" =~ $DOMAINREGEX ]]; then
    rerun_log debug ">> Invalid host name, returning";
    return 10;
  fi
  if [[ ! "${2}" =~ $IPREGEX ]]; then
    rerun_log debug ">> Invalid ip address, returning";
    return 20;
  fi
  return 0;
}

function createHostFileByTemplate {
  # Usage: createHostFileByTemplate <destPath> <template1> ... <templateN>
  #
  # Creates a new host file (if not exists) and asks user for permission and
  # if file shall be based on one of the given templates.
  #
  # @args:
  #   str destPath:     The path where the new file shall be created
  #   str template1..N: The selectable templates, which new file shall be based
  #                     on
  #
  # @version: 1.0
  # @see: rerun_log
  # @examples:
  #   createHostFileByTemplate "${HFM_DIR}/newenvironment" ${HFM_DIR}/*
  # @errors:
  #   10: Empty <destPath> given
  #   20: <destPath> already exists
  #   30: Parent directory of <destPath> does not exist
  #   40: User disallowed creation of <destPath>
  #
  rerun_log debug "Entering createHostFileByTemplate function with $# arguments";
  local USEDEFF PTEXT DESTPATH;
  DESTPATH="${1}";
  [ -z "${1}" ] && return 10;
  [ -f "${1}" ] && return 20;
  [ ! -d "$(dirname ${1})" ] && return 30;

  PTEXT="A new file at ${DESTPATH} is needed. Shall one be created?"
  read -p $'\n'"${PTEXT}" USEDEFF;

  if [[ ${USEDEFF} == y* || ${USEDEFF} == Y* ]]; then
    shift;
    local ISONEVALID=false;
    declare -a TPLS=();
    declare -a TPLSPATH=();

    for i in "$@"; do
      [ ! -f "$i" ] && continue;
      ISONEVALID=true;
      TPLS+=("$(basename $i)");
      TPLSPATH+=("$i");
    done

    if [ $ISONEVALID ]; then
      local NANS="Dont use a template" TPLPATH="";
      TPLS+=("${NANS}");
      PS3="The following templates are available. Choose one if you want: ";

      select opt in "${TPLS[@]}"; do
        [ "${opt}" == "${NANS}" ] && ISONEVALID=false && break;

        for i in "${TPLSPATH[@]}"; do
          [ "${opt}" == "$(basename ${i})" ] && TPLPATH="${i}" && break;
        done
      done

      [ -f "${TPLPATH}" ] && cp ${TPLPATH} ${i};
    fi

    if [ ! $ISONEVALID ]; then
      echo "##"$'\n'"#"$'\n'"# hfm host file for \
            $(basename ${DESTPATH%.*}) environment" >> ${1};
    fi
  else
    rerun_log debug ">> User disallowed creation of ${1}";
    return 40;
  fi
}

function addHostToFileIfNotExists {
  # Usage: addHostToFileIfNotExists <filePath> <host> <ipaddress>
  #
  # Adds an host with its address to specified file.
  #
  # @args:
  #   str filePath:  The path to the (host)file, where the host shall be added
  #   str ipaddress: The ip address of the host
  #
  # @version: 1.0
  # @see: rerun_log, checkHostAndIPAddress
  # @examples:
  #   addHostToFileIfNotExists /etc/hosts "newhost.dev www.newhost.dev" 127.0.0.1
  # @errors:
  #   10-20: see checkHostAndIPAddress
  #   30:    Invalid host file path given
  #
  rerun_log debug "Entering addHostToFileIfNotExists function with $# arguments";
  local RETV;

  [ ! -f "$1" ] && return 30;
  checkHostAndIPAddress "$2" "$3";
  RETV=$?
  [ ${RETV} -ne 0 ] && return ${RETV};

  echo -e "${3}\t${2}" >> "${1}"
  return 0;
}