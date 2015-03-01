#!/bin/bash
# Shell functions for the add command of hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/add-functions.sh
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# - - -
# Functions declared here.
# - - -
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