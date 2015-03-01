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
  [ -z "${1}" ] && return 10;
  for i in $(echo "${1}" | tr " " "\n"); do
    if [[ ! "$i" =~ $DOMAINREGEX ]]; then
      rerun_log debug ">> Invalid host name ($i), returning";
      return 10;
    fi
  done
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

  PTEXT="A new file at ${DESTPATH} is needed."$'\n'"Shall one be created? (y/n) "
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

    if [ $ISONEVALID == true ]; then
      local NANS="Dont use a template" TPLPATH="" OLDPSV="";
      TPLS+=("${NANS}");
      OLDPSV="${PS3+}";
      rerun_log info "The following templates are available. Choose one if you want: ";
      PS3="Your selection: ";

      select opt in "${TPLS[@]}"; do
        [ "${opt}" == "${NANS}" ] && ISONEVALID=false && break;

        for i in "${TPLSPATH[@]}"; do
          [ "${opt}" == "$(basename ${i})" ] && TPLPATH="${i}";
        done
        [ -f "${TPLPATH}" ] && break;
      done

      PS3="${OLDPSV}";
      [ -f "${TPLPATH}" ] && cp ${TPLPATH} ${DESTPATH};
    fi

    if [ $ISONEVALID == false ]; then
      echo "##"$'\n'"#"$'\n'"# hfm host file for \
$(basename ${DESTPATH}) environment" >> "${DESTPATH}";
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
  #   str host:      The hostname
  #   str ipaddress: The ip address of the host
  #
  # @version: 1.0
  # @see: rerun_log, checkHostAndIPAddress
  # @examples:
  #   addHostToFileIfNotExists /etc/hosts "newhost.dev www.newhost.dev" 127.0.0.1
  # @errors:
  #   10-20: see checkHostAndIPAddress
  #   30:    Invalid host file path given
  #   40:    Host exists already in <filePath>
  #
  rerun_log debug "Entering addHostToFileIfNotExists function with $# arguments";
  local RETV;

  [ ! -f "$1" ] && return 30;
  checkHostAndIPAddress "$2" "$3";
  RETV=$?
  [ ${RETV} -ne 0 ] && return ${RETV};

  for i in $(echo "${2}" | tr " " "\n"); do
    if [ $(cat ${1} | grep ${i} | wc -l | sed 's/^ *//g') -ne 0 ]; then
      rerun_log warn ">> The host ${i} is already in the hosts file ${1}.";
      return 40;
    fi;
  done

  echo -e "${3}\t${2}" >> "${1}"
  return 0;
}

function rmHostFromFile {
  # Usage: rmHostFromFile <filePath> <hosts>
  #
  # Removes an host with its address from the specified file.
  #
  # @args:
  #   str filePath:  The path to the (host)file, where the host shall be added
  #   str hosts:     A space seperated list of hostnames
  #
  # @version: 1.0
  # @see: rerun_log
  # @examples:
  #   rmHostFromFile /etc/hosts "newhost.dev www.newhost.dev" 127.0.0.1
  # @errors:
  #   10: <filePath> does not exist
  #   20: Cannot create temporary file
  #
  rerun_log debug "Entering rmHostFromFile function with $# arguments";
  local RETV;

  [ ! -f "$1" ] && return 10;

  tempfoo=`basename $0`
  TMPFILE=`mktemp -q /tmp/${tempfoo}.XXXXXX`
  trap "rm -f ${TMPFILE}" EXIT INT;
  if [ $? -ne 0 ]; then
     rerun_log debug ">> Can't create temp file, returning"
     return 20;
  fi

  for i in $(echo "${2}" | tr " " "\n"); do
    cat "$1" | sed -e "/$2\$/ d" > "${TMPFILE}" && mv "${TMPFILE}" "$1"
    return $?;
  done
  return 0;
}