#! /usr/bin/env bash
# @name parse_parms_lib
# @short parsing functions
# @description
#  This library contains a number of parsing functions.  All functions have the
#  a similar theory of operation.  Users of the function pass in the name of an ARGV
#  list, as the first parameter, and the name of an associative array as the
#  second function.  The parser will add the parameters into the associative
#  array as required, and return in the ARGV list the unused parameters.

# @description parse positional arguments up to first non argument '^--arg=bar'
#
# @example
#    parse_arguments --ARGV=argv --ARGN=options --foo=bar --bar=baz then --more
#
# @arg --ARGV=var (array) A pointer to the arguments after the
#
# @arg --ARGN=var (assoc_array) A pointer to the options associative array
#
# @arg --*key*=*val* (string) Arbitrary key value parameters
#
# @exitcode 0 If successful.
# @exitcode 1 On errors
#
function parse_parms.arguments () {
	local existing_named
  while [[ "$1" =~ ^--ARG[NV] ]]; do
    if [[ "$1" =~ ^--ARGV=..* ]]; then
      local -n ARGV=${1/--ARGV=}
    elif  [[ "$1" =~ ^--ARGN=..* ]]; then
      local -n ARGN=${1/--ARGN=}
    fi
    shift
  done

	while [[ "$1" =~ ^-- ]]; do
    # '--' is an auto stop
    if [[ "$1" == "--" ]]; then
      shift;
      break;
    fi
		# Escape asterisk to prevent bash asterisk expansion, and quotes to prevent string breakage
		_escaped=${1/\*/\'\"*\"\'}
		_escaped=${_escaped//\'/\\\'}
		_escaped=${_escaped//\"/\\\"}
		# If equals delimited named parameter
		nonspace="[^[:space:]]"
		if [[ "$1" =~ ^--${nonspace}*=..* ]]; then
			# key is part before first =
			local _key=$(echo "$1" | cut -d = -f 1)
			# Just add as non-named when key is empty or contains space
			if [[ "$_key" == "" || "$_key" =~ " " ]]; then
        >$2 echo "parse_arguments: bad key: $1"
        return 1
			fi
			# val is everything after key and = (protect from param==value error)
			local _val="${1/$_key=}"
			# remove dashes from key name
			_key=${_key#--}
			# search for existing parameter name
			if (echo "$existing_named" | grep "\b$_key\b" >/dev/null); then
				# if name already exists then it's a multi-value named parameter
				# re-declare it as an array if needed
				if ! (declare -p _key 2> /dev/null | grep -q 'declare \-a'); then
					echo "$_key=(\"\$$_key\");"
				fi
				# append new value
				echo "$_key+=('$_val');"
			else
				# single-value named parameter
				ARGN[$_key]="$_val"
				existing_named=" $_key"
			fi
		# If standalone named parameter
		elif [[ "$1" =~ ^\-${nonspace}+ ]]; then
			# remove dashes
			local _key=${1#--}
      #These are binary options --flag and --no-flag
      if [[ "$1" =~ ^\no- ]]; then
        _key=${_key#no-};
        ARGN["$_key"]=0
        ARGN["no-${_key}"]=1
      else
			  ARGN["$_key"]=1
			  ARGN["no-${_key}"]=0
      fi
		# non-named parameter
		else
			# Escape asterisk to prevent bash asterisk expansion
			_escaped=${1/\*/\'\"*\"\'}
			echo "ARGV+=('$_escaped');"
		fi
		shift
	done

  # Add Remaining Parms
  ARGV+=("$@")
}


# @description: Universal Bash parameter parsing
#   Parse equal sign separated params into named local variables
#   Standalone named parameter value will equal its param name (--force creates variable $force=="force")
#   Parses multi-valued named params into an array (--path=path1 --path=path2 creates ${path[*]} array)
#   Puts un-named params as-is into ${ARGV[*]} array
#   Additionally puts all named params as-is into ${ARGN[*]} array
#   Additionally puts all standalone "option" params as-is into ${ARGO[*]} array
# @author Oleksii Chekulaiev
# @version v1.4.1 (Jul-27-2018)
function parse_params.local_eval() {
    local existing_named
    local ARGV=() # un-named params
    local ARGN=() # named params
    local ARGO=() # options (--params)
    echo "local ARGV=(); local ARGN=(); local ARGO=();"
    while [[ "$1" != "" ]]; do
        # Escape asterisk to prevent bash asterisk expansion, and quotes to prevent string breakage
        _escaped=${1/\*/\'\"*\"\'}
        _escaped=${_escaped//\'/\\\'}
        _escaped=${_escaped//\"/\\\"}
        # If equals delimited named parameter
        nonspace="[^[:space:]]"
        if [[ "$1" =~ ^${nonspace}${nonspace}*=..* ]]; then
            # Add to named parameters array
            echo "ARGN+=('$_escaped');"
            # key is part before first =
            local _key=$(echo "$1" | cut -d = -f 1)
            # Just add as non-named when key is empty or contains space
            if [[ "$_key" == "" || "$_key" =~ " " ]]; then
                echo "ARGV+=('$_escaped');"
                shift
                continue
            fi
            # val is everything after key and = (protect from param==value error)
            local _val="${1/$_key=}"
            # remove dashes from key name
            _key=${_key//\-}
            # skip when key is empty
            # search for existing parameter name
            if (echo "$existing_named" | grep "\b$_key\b" >/dev/null); then
                # if name already exists then it's a multi-value named parameter
                # re-declare it as an array if needed
                if ! (declare -p _key 2> /dev/null | grep -q 'declare \-a'); then
                    echo "$_key=(\"\$$_key\");"
                fi
                # append new value
                echo "$_key+=('$_val');"
            else
                # single-value named parameter
                echo "local $_key='$_val';"
                existing_named=" $_key"
            fi
        # If standalone named parameter
        elif [[ "$1" =~ ^\-${nonspace}+ ]]; then
            # remove dashes
            local _key=${1//\-}
            # Just add as non-named when key is empty or contains space
            if [[ "$_key" == "" || "$_key" =~ " " ]]; then
                echo "ARGV+=('$_escaped');"
                shift
                continue
            fi
            # Add to options array
            echo "ARGO+=('$_escaped');"
            echo "local $_key=\"$_key\";"
        # non-named parameter
        else
            # Escape asterisk to prevent bash asterisk expansion
            _escaped=${1/\*/\'\"*\"\'}
            echo "ARGV+=('$_escaped');"
        fi
        shift
    done

    function parse_params.local_eval.example() {
      echo 'eval $(parse_parms.local_eval param 1" --anyparam="my value" param2 k=5 --force --multi-value=test1 --multi-value=test2)'
      eval $(parse_params.local_eval "param 1" --anyparam="my value" param2 k=5 --force --multi-value=test1 --multi-value=test2)
      # --
      echo "${ARGV[0]}" # print first unnamed param
      echo "${ARGV[1]}" # print second unnamed param
      echo "${ARGN[0]}" # print first named param
      echo "${ARG0[0]}" # print first option param (--force)
      echo "$anyparam"  # print --anyparam value
      echo "$k"         # print k=5 value
      echo "${multivalue[0]}" # print first value of multi-value
      echo "${multivalue[1]}" # print second value of multi-value
      [[ "$force" == "force" ]] && echo "\$force is set so let the force be with you"
    }
}

#--------------------------- DEMO OF THE USAGE -------------------------------


if [[ -z ${parse_parms_lib_no_info} ]]; then
  >&2 echo "parse_parms_lib"
fi
