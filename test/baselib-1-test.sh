#!/usr/bin/env roundup
#
# Baselib test
#/ usage: rerun stubbs:test -m MODULE -p baselib
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# Include baselib file
# -----------------
BASELIB_PATH="${RERUN_MODULES}/$(dirname ..)/lib/baselib.sh";
if [ ! -f ${BASELIB_PATH} ]; then
    exit;
fi

source ${BASELIB_PATH};