# Shell functions for the hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/baselib.sh command
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# - - -
# Constants declared here.
# - - -
HOST_FILE_LOC="/etc/host";
HFM_DIR="${HOME}/.hfm";
DEFAULT_FILE="$HFM_DIR/default";

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
  # @errors:
  #   10: Given directory already exists.
  #   20: Given directory is not writable.
  #   30: Could not create directory.
  #   40: User did not allow creation of directory.
  #
  local ANS, MKDIRRV;
  rerun_log debug "Entering createDirIfNotExists with ${#} arguments";

  [ -d "${1}" ] && {
    rerun_log debug ">> Directory \"${1}\" already exists.";
    return 10;
  }

  [ -w "${1}" ] && {
    rerun_log debug ">> Directory \"${1}\" already exists but is not writable.";
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