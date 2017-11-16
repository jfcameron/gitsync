#!/bin/bash 
#!/bin/sh

#---------------------------------------------------------------------
# Configuration
#---------------------------------------------------------------------
USER="jfcameron"
PATH_TO_WORKSPACE=~/Workspace

#---------------------------------------------------------------------
# Provide file header comment *and* use same as help information
#---------------------------------------------------------------------
printHelp () {
sed 's/^# \{0,1\}//' << Help
#---------------------------------------------------------------------
#
# $progName -- help info 
#
# Summary:
#
# $shortProgName: [ -X -V -h ] otherParams
#       option: -X >> turn on shell debugging (set -v) 
#       option: -V >> verbose, turns on INFO messages
#       option: -h >> print this help page
#
# Description:
#
# Example Usage:
#       $shortProgName -X -V
#
#---------------------------------------------------------------------
Help
}

#---------------------------------------------------------------------
# Print info, warning, or error and eit
#---------------------------------------------------------------------
Log()   { echo -e "$shortProgName:" "$@"; }
Info()  { if [ x$verbose = xTRUE ]; then echo "$shortProgName: Info:" "$@"; fi; }
Warn()  { echo -e "$shortProgName: \033[1;33mWarning:\033[0m" "$@"; }
Error() { echo -e "$shortProgName: \033[1;31mError:\033[0m"   "$@" >/dev/stderr; exit 1; }

#---------------------------------------------------------------------
# Misc utility functions
#---------------------------------------------------------------------
tolower( ) {
       echo $* | tr '[:upper:]' '[:lower:]'
}

# ---------------------------------------------------------------------
# Implementation
# ---------------------------------------------------------------------
function clone()
{
  Log clone $1
  pushd $PATH_TO_WORKSPACE > /dev/null

  if [ $1 == --personal ] || [ $1 == -p ] || [ $1 == -a ] || [ $1 == --all ]; then
    echo "\033[1;33mCloning User Repos\033[0m"
    curl "https://api.github.com/users/$USER/repos?page=1&per_page=1" |
      grep -e 'git_url*' |
      cut -d \" -f 4 |
      xargs -L1 git clone
  fi

  if [ $1 == --starred ] || [ $1 == -s ] || [ $1 == -a ] || [ $1 == --all ]; then
  echo "\033[1;33mCloning Starred Repos\033[0m"
  curl "https://api.github.com/users/$USER/starred?page=1&per_page=1" |
    grep -e 'git_url*' |
    cut -d \" -f 4 |
    xargs -L1 git clone
  fi

  popd > /dev/null
}

function pull()
{
  Log pull $1
  pushd $PATH_TO_WORKSPACE > /dev/null

  NO_STYLE='\033[0m'
  REPO_STYLE='\033[38;5;3m'
  UPTODATE_STYLE='\033[0;32m'
  NEEDUPDATE_STYLE='\033[0;31m'
  NL='
  '

  for repo in ./*/.git; do 
  (
    repo=${repo%.*}
    
    printf "Repo: ${REPO_STYLE}${repo}${NO_STYLE}\n";
    
    cd $repo
    
    git fetch --all
    git submodule update --init --recursive
    git status
    
    if [[ $( git status ) != *"Your branch is up-to-date"* ]]; then
      printf "${NEEDUPDATE_STYLE}Updating...${NO_STYLE}\n"
      git pull
    else
      printf "${UPTODATE_STYLE}Already up-to-date.${NO_STYLE}\n"
    fi

    cd ..

    echo

  ); done

  popd > /dev/null
}

function push()
{
  Log "push"
  pushd $PATH_TO_WORKSPACE > /dev/null



  popd > /dev/null
}

#---------------------------------------------------------------------
# Mainline begins here
#---------------------------------------------------------------------
progName=$0
shortProgName=`echo $progName|sed 's/^.*\///'`
verbose=''
initialArgs="$@"

while true; do 
  case $1 in
    clone | pull)
      command=$1 
      shift
      case $1 in
        -a | --all | -s | --starred | -p | --personal) $command $1;;
        *) if [ "${1}" != '' ]; then 
          Error "$1 unrecognized argument of $command" 
        else 
          Error "$command requires an argument" 
        fi
      ;;
      esac
    ;;

    push)
      push
    ;;

    -h | --help) printHelp;;

    *) 
      if [ "${1}" != '' ]; then
        Error "unrecognized option: '$1' Use '-h' for help"
      fi
      break
    ;;
  esac
  shift
done

#--------------
# The following is just some code to illustrate use of the Info / Confirm / etc
# functions
#--------------
if [ x$table = 'xTRUE' ]; then 
       Info "Table is true" 
else
       Info "Table is false"
fi
