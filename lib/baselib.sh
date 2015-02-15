# Shell functions for the hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/baselib.sh
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# - - -
# Functions declared here.
# - - -
function createDirIfNotExists {
  # Usage: createDirIfNotExists <atPath>
  #
  # Creates a directory if not exists and if one gets created
  # asks the user before.
  #
  # @args:
  #   str atPath: The path, where the new directory shall be created.
  #
  # @version: 1.0
  # @see: rerun_log
  # @examples:
  #   createDirIfNotExists ${HFM_DIR}
  # @errors:
  #   10: No atPath given
  #   20: Given directory already exists.
  #   30: Could not create directory.
  #   40: User did not allow creation of directory.
  #
  local ANS MKDIRRV;
  rerun_log debug "Entering ${FUNCNAME} with ${#} arguments";

  [ -z "${1}" ] && {
    rerun_log debug ">> Wrong arguments. Call: ${FUNCNAME} <atPath>";
    return 10;
  }

  [ -d "${1}" ] && {
    rerun_log debug ">> Directory \"${1}\" already exists.";
    return 20;
  }

  # Everything ready to create directory, so ask user.
  read -p "A directory at \"${1}\" is required.\
           Shall one be created now? (y/n)" ANS;

  # Check if ANS begins with "y" or "Y"
  if [[ ${ANS} == y* || ${ANS} == Y* ]]; then
    rerun_log info "Creating directory at \"${1}\"";
    mkdir -p "${1}";

    MKDIRRV=$?;
    if [ ${MKDIRRV} -ne 0 ]; then
      rerun_log debug ">> mkdir returned \"${MKDIRRV}\"";
      return 30;
    fi

    return 0;
  else
    rerun_log debug ">> User did not allow creation of directory at \"${1}\"";
    return 40;
  fi
}

function createFileByCpIfNotExists {
  # Usage: createFileByCpIfNotExists <fromPathSuggestion> <atPath>
  #
  # Copies a file from a suggested path if user agrees and file
  # does not exists already.
  #
  # @args:
  #   str fromPathSuggestion: A suggestion path, where the file shall be copied
  #                           from.
  #   str atPath: The path, where the file shall be copied to.
  #
  # @version: 1.0
  # @see: rerun_log
  # @examples:
  #   createFileByCpIfNotExists /etc/host ${HFM_DIR}/default
  # @errors:
  #   10: <fromPathSuggestion> is empty.
  #   20: <fromPathSuggestion> is not a valid path to a file.
  #   30: <atPath> is empty.
  #   40: User disallowed using <fromPathSuggestion> as source for file.
  #
  rerun_log debug "Entering ${FUNCNAME} with ${#} arguments";
  local USEDEFF PTEXT="" NEEDROOT="n";

  if [ ! -f "${2}" ]; then
    if [ -z "${1}" ]; then
      rerun_log debug ">> Empty/No <fromPathSuggestion> provided";
      return 10;
    elif [ ! -f "${1}" ]; then
      rerun_log debug ">> Suggested source file at ${1} does not exist";
      return 20;
    else
      if [ ! -w "$(dirname \"${2}\")" ]; then
        NEEDROOT="y";
    fi;

    if [ -z "${2}" ]; then
      rerun_log debug ">> Empty/No <atPath> provided";
      return 30;
    else
      rerun_log debug ">> File at '${2}' does not exist";
    fi

    PTEXT="No file found at ${2}, shall ${1} be copied there";
    [ "${NEEDROOT}" == "y" ] && PTEXT="${PTEXT} (will run with sudo)"
    PTEXT="${PTEXT}? (y/n)";
    read -p "${PTEXT}" USEDEFF;

    if [[ ${USEDEFF} == y* || ${USEDEFF} == Y* ]]; then
      rerun_log info "Creating file '${2}' by copying '${1}'";
      [ "${NEEDROOT}" == "y" ] && sudo cp "${1}" "${2}" || cp "${1}" "${2}";
    else
      rerun_log debug ">> User disallowed coping ${1} to ${2}";
      return 40;
    fi
  else
    rerun_log debug ">> File ${2} already exists. All right then";
    return 0;
  fi
}