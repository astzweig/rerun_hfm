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
  local DOMAINREGEX="^[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]+$";
  local IPREGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$";
  rerun_log info "Entering checkHostAndIPAddress function with $# arguments";
  if [[ ! "$1" =~ $DOMAINREGEX ]]; then
    rerun_log info ">> Invalid host name, returning";
    return 10;
  fi
  if [[ ! $IP =~ $IPREGEX ]]; then
    rerun_log info ">> Invalid ip address, returning";
    return 20;
  fi
  return 0;
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
  rerun_log info "Entering addHostToFileIfNotExists function with $# arguments";
  [ ! -f "$1" ] && return 30;
  checkHostAndIPAddress "$2" "$3";
  if [ $? -ne 0 ]; then
    rerun_log ">> Invalid arguments provided, returning";
    return $?;
  fi

  echo -e "${3}\t${2}" >> "${1}"
  return 0;
}