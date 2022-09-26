#! /usr/bin/env bash
# @name bash_functions
# @short standard bash functions
# @description
#
# bash_functions is a set of sharable bash functions.  This library contains
# functions for initializing the function libary, and other general tasks
#
# @description import a library
#
# @example
#    bash_functions.import parse_parms_lib
#
# @arg $1 library to import
#
# @exitcode 0 If successful.
# @exitcode 1 On errors
#
function bash_functions.import () {
  local path=${BASH_FUNCTIONS} || $(dirname $0)/../lib/$(basename $0)
  local fn=${path}/$1.sh
  if [[ -f $fn ]] ; then
    source $fn;
    $1.import
  else
    >&2 echo "bash_functions.import: $fn not found"
    return 1
  fi
}

if [[ -z ${bash_functions_no_info} ]]; then
  >&2 echo "bash_functions.sh"
fi
