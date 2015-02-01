# Shell functions for the hfm module.
#/ usage: source RERUN_MODULE_DIR/lib/functions.sh command
#
# Author: Thomas Stahler <thomas.stahler@idn.astzweig.de>
#

# Read rerun's public functions
. $RERUN || {
    echo >&2 "ERROR: Failed sourcing rerun function library: \"$RERUN\""
    return 1
}

# Check usage. Argument should be command name.
[[ $# = 1 ]] || rerun_option_usage

# Source the option parser script.
#
if [[ -r $RERUN_MODULE_DIR/commands/$1/options.sh ]] 
then
    . $RERUN_MODULE_DIR/commands/$1/options.sh || {
        rerun_die "Failed loading options parser."
    }
fi

# Include general functions needed by all commands
if [ -f "${RERUN_MODULE_DIR}/lib/baselib.sh" ]; then
  source "${RERUN_MODULE_DIR}/lib/baselib.sh" || {
    rerun_log warn "Could not source >baselib.sh<. Resuming tough.";
    return 0;
  };

  # Run proxy functions
  # @TODO: check if shell compatible with other shells
  for funcs in $(declare -f | grep '^f_*' | sed 's/()//g'); do
    $funcs;
  done
fi

# - - -
# Your functions declared here.
# - - -

# Include command specific functions
for file in $(ls ${RERUN_MODULE_DIR}/lib/*${1}-functions.sh 2> /dev/null);
do
  if [ -f "${file}" ]; then
    source "${file}" || {
      rerun_log error "Could not include ${file}. Resuming tough.";
      return 0;
    };
  fi
done;
