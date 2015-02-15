# Shell functions for the hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/initializers.sh
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
                  "${HOST_FILE_LOC}" "${DEFAULT_FILE}");

    if [ ! -f "${DEFAULT_FILE}" ]; then
      rerun_die 20 "Please provide a default hosts file \
        with default entries at ${DEFAULT_FILE}";
    fi
  fi
}