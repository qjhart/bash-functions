. parse_parms_lib.sh

declare -a cmd_line

declare -A opts
opts[foo]="quinn"

parse_cmd --ARGV=cmd_line --ARGN=opts "$@"

for i in ${!opts[@]}; do echo "opts[$i]=${opts[$i]}"; done
echo "rest: ${cmd_line[@]}"
