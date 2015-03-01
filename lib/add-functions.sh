#!/bin/bash
# Shell functions for the add command of hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/add-functions.sh
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# - - -
# Constants declared here.
# - - -
DOMAINREGEX="^[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]+$";
IPREGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$";


# - - -
# Functions declared here.
# - - -
function checkHostAndIPAddress {
  # Usage: checkHostAndIPAddress host ipaddress
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
  #   20: Invalid IP address given.
  #
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
  # Usage: addHostToFileIfNotExists <filePath> <address> <hosts>
  #
  # Adds an host with its address to specified file.
  #
  # @args:
  #   str filePath: The path to the (host)file, where the host shall be added
  #   str address:  The ip address of the host
  #
  # @version: 1.0
  # @see: rerun_log
  # @examples:
  #   addHostToFileIfNotExists /etc/hosts 127.0.0.1 "newhost.dev www.newhost.dev"
  #
}