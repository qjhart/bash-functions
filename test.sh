#! /bin/bash

. parse_parms_lib.sh

 function a() {
   declare -A opts
   declare -a argv

   opts[foo]="quinn"
   parse_cmd --ARGV=argv --ARGN=opts "$@"

   for i in ${!opts[@]}; do echo "opts[$i]=${opts[$i]}"; done
   echo "rest: ${argv[@]}"

   set "${argv[@]}"
   cmd=$1
   shift

  echo "then $cmd"

   echo "B"
   b "$@"
   echo "DONE"
 }

function b() {
  declare -A opts
  declare -a cmd_line

  opts[quinn]="is great"
  parse_cmd --ARGV=cmd_line --ARGN=opts "$@"

  for i in ${!opts[@]}; do echo "opts[$i]=${opts[$i]}"; done
  echo "rest: ${cmd_line[@]}"

  }

a "$@"

#declare -A opts
#declare -a cmd_line

#opts[foo]="quinn"
#parse_cmd --ARGV=cmd_line --ARGN=opts "$@"
#for i in ${!opts[@]}; do echo "opts[$i]=${opts[$i]}"; done
# echo "rest: ${cmd_line[@]}"
