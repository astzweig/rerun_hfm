# Shell functions for the hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/baselib.sh
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# - - -
# Constants declared here.
# - - -
HOST_FILE_LOC="/etc/host";
HFM_DIR="${HOME}/.hfm";
DEFAULT_FILE="$HFM_DIR/default";

if [ -z "$(declare -f | grep '^rerun_log' | sed 's/()//g')" ]; then
  function rerun_log {
    echo $2 1>&2 ;
  }
fi


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
  # Usage: createFileByCpIfNotExists <atPath> <fromPathSuggestion>
  #
  # Copies a file from a suggested path if user agrees and file
  # does not exists already.
  #
  # @args:
  #   str atPath: The path, where the file shall be copied to.
  #   str fromPathSuggestion: A suggestion path, where the file shall be copied from.
  #
  # @version: 1.0
  # @see: rerun_log
  # @examples:
  #   createFileByCpIfNotExists ${HFM_DIR}/default /etc/host
  # @errors:
  #   10: <fromPathSuggestion> is not a valid path to a file.
  #   20: User disallowed using <fromPathSuggestion> as source for file.
  #
  if [ ! -f "${1}" ]; then
    local USEDEFF;

    if [ ! -f "${2}" ]; then
      rerun_log debug "File at ${1} doesn't exist and suggested source file \
      at ${2} does not exist either.";
      return 10;
    fi

    read -p "No file found at ${1}, shall ${2} be copied there? (y/n)" USEDEFF;

    if [[ ${USEDEFF} == y* || ${USEDEFF} == Y* ]]; then
      rerun_log debug ">> mkdir \"${DEFAULT_FILE}\"";
      cp "${2}" "${1}";
    else
      rerun_log debug "User disallowed coping ${2} to ${1}";
      return 20;
    fi
  else
    rerun_log debug "File ${1} already exists. All right then.";
    return 0;
  fi
}

# - - -
# Proxy functions declared here.
# (= functions without own functionality, which only call other functions)
# - - -
function f_checkIfAppAlreadyInitialized {
  # Usage: checkIfAppAlreadyInitialized
  #
  # @version: 1.0
  local RETURNVAL;
  if [ ! -d "${HFM_DIR}" ]; then
    RETURNVAL=$(createDirIfNotExists "${HFM_DIR}");

    if [ ! -d "${HFM_DIR}" ]; then
      rerun_die 10 "Could not create default app dir. Aborting...";
    fi
  fi

  if [ ! -f "${DEFAULT_FILE}" ]; then
    RETURNVAL = $(createFileByCpIfNotExists
                  "${DEFAULT_FILE}" "${HOST_FILE_LOC}");

    if [ ! -f "${DEFAULT_FILE}" ]; then
      rerun_die 20 "Please provide a default hosts file \
        with default entries at ${DEFAULT_FILE}";
    fi
  fi
}