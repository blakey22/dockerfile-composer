#!/bin/bash
#
# title        :configute.sh
# description  :Compose Dockerfile from snippet(s)
# author       :Blake
#----------------------------------------------------

# Setup variables
SNIPPET_PATH="./resources/snippet"
DOCKER_FILE="Dockerfile"

# Color definitions
COLOR_WHITE='\033[1;97m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_OFF='\033[0m'

# Snippet variables
SNIPPET_NAME=""
SNIPPET_VERSION=""

function failure {
  echo -e "${COLOR_RED}[FATAL] ${1}${COLOR_OFF}"
  exit 1
}

function success {
  if [ "${#1}" -gt 1 ]; then
    echo -e "${COLOR_GREEN}[SUCCESS] ${1}${COLOR_OFF}"
  fi
  exit 0
}

function warning {
  echo -e "${COLOR_YELLOW}[WARNING] ${1}${COLOR_OFF}"
}

function get_snippet_info {
  SNIPPET_NAME=`echo $1 | cut -d = -f 1`
  SNIPPET_VERSION=`echo $1 | cut -s -d = -f 2`
}

function check_snippet_existed {
  get_snippet_info $1
  if [ ! -f "$SNIPPET_PATH/$SNIPPET_NAME" ]; then
    failure "Snippet '$1' not found!"
  fi
}

function write_snippet {
  get_snippet_info $1
  AP_NAME=`echo $SNIPPET_NAME | tr '[a-z]' '[A-Z]'`
  echo "# Snippet: $SNIPPET_NAME" >> "$2"
  # replace snippet version when append to Dockerfile
  if [ ${#SNIPPET_VERSION} -ne 0 ]; then
    grep -q "ENV ${AP_NAME}_VERSION" "$SNIPPET_PATH/$SNIPPET_NAME"
    if [ $? -ne 0 ]; then
      warning "Unable to replace ${SNIPPET_NAME} version, please make sure 'ENV ${AP_NAME}_VERSION x.y.z' existed is '$SNIPPET_PATH/$SNIPPET_NAME'."
    fi
    sed "s/ENV ${AP_NAME}_VERSION.*/ENV ${AP_NAME}_VERSION $SNIPPET_VERSION/g" "$SNIPPET_PATH/$SNIPPET_NAME" >> "$2"
  else
    cat "$SNIPPET_PATH/$SNIPPET_NAME" >> "$2"
  fi
  echo "" >> "$2"
}

function escape_regex {
  result=`echo $1 | sed 's/\//\\\\\//g'`
  echo "$result"
}

function get_available_snippets {
  local -a ret=()
  count=0
  for var in "$SNIPPET_PATH"/*
  do
    escape_pattern=$(escape_regex $SNIPPET_PATH)
    entry=`echo $var | sed "s/$escape_pattern\///g"`
    # omit snippet name starts with "_"
    if [[ "$entry" == _* ]]; then
      continue
    fi
    ret[$count]=$entry
    count=$(( $count + 1 ))
  done
  echo ${ret[@]}
}

function print_help {
  local indent="  "
  declare -a snippets=()
  snippets=$(get_available_snippets)

  echo -e "${COLOR_WHITE}NAME${COLOR_OFF}"
  echo -e "${indent}$0 -- compose Dockerfile from snippet(s)\n"
  echo -e "${COLOR_WHITE}AVAILABLE SNIPPETS${COLOR_OFF}"
  for i in ${snippets[@]}; do
    echo "${indent}$i"
  done
  echo ""
  echo -e "${COLOR_WHITE}EXAMPLES${COLOR_OFF}"
  echo "${indent}$0 --base"
  echo "${indent}$0 gcc jdk"
  echo "${indent}$0 pip jdk=7u79-b15"
  echo ""
  success
}

# handle arguments
if [ "$#" -lt 1 ]; then
  print_help
elif [ "$1" == "--base" ]; then
  # pop up other arguments
  for var in "$@";
  do
    shift
  done
fi

for var in "$@";
do
  check_snippet_existed $var
done

# compose Dockerfile
cat $SNIPPET_PATH/_header > $DOCKER_FILE
for var in "$@";
do
  write_snippet $var $DOCKER_FILE
done
cat $SNIPPET_PATH/_footer >> $DOCKER_FILE
success "Composed file: $DOCKER_FILE"
