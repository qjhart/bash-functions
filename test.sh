#! /bin/bash

. parse_parms_lib.sh
parse_parms.import

function a() {
  local opts
  declare -A opts
  declare -a argv

  echo "a(){"
  opts[a_def_foo]="quinn"
  parse_parms.arguments --ARGV=argv --ARGN=opts "$@"

   for i in ${!opts[@]}; do echo "opts[$i]=${opts[$i]}"; done
   echo "rest: ${argv[@]}"

   set "${argv[@]}"
   cmd=$1
   shift

   echo "cmd=$cmd"

   b "$@"
   echo "} a()"
 }

function b() {
  declare -a cmd_line
  echo "b(){"
  declare -p opts >/dev/null 2>/dev/null
  [[ $? -eq 0 ]]  || local -A opts

  opts[b_def_quinn]="is great"
  parse_parms.arguments --ARGV=cmd_line --ARGN=opts "$@"

  for i in ${!opts[@]}; do echo "opts[$i]=${opts[$i]}"; done
  echo "rest: ${cmd_line[@]}"
  echo "} #b()"
  }

b
a "$@"

#declare -A opts
#declare -a cmd_line

#opts[foo]="quinn"
#parse_cmd --ARGV=cmd_line --ARGN=opts "$@"
#for i in ${!opts[@]}; do echo "opts[$i]=${opts[$i]}"; done
# echo "rest: ${cmd_line[@]}"
