#!/bin/bash 
#!/bin/sh

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
Log()   { echo "$shortProgName:" "$@"; }
Info()  { if [ x$verbose = xTRUE ]; then echo "$shortProgName: Info:" "$@"; fi; }
Warn()  { echo "$shortProgName: Warning:" "$@"; }
Error() { echo "$shortProgName: Error:"   "$@" >/dev/stderr; exit 1; }

#---------------------------------------------------------------------
# Confirm or eit
#---------------------------------------------------------------------
Confirm () {
       read -p "$shortProgName: $*? [y/n] " confirmAnswer
       if [ x$confirmAnswer != xy -a x$confirmAnswer != xY ]; then 
             Info "Exiting/Not Confirmed: $*"
             exit 2;
       fi
       Info "Confirmed: $*"
}

Dialog () {
       read -p "$shortProgName: $*: " dialogAnswer 
       Info "Dialog: $*: $dialogAnswer"
}

DialogNoEcho () {
       trap 'stty echo; exit'  1 2 3 15
       stty -echo
       read -p "$shortProgName: $*: " dialogAnswer 
       echo '...'
       stty echo
       trap -  1 2 3 15
       Info "DialogNoAnswer: $*: $dialogAnswer"
}

#---------------------------------------------------------------------
# Misc utility functions
#---------------------------------------------------------------------
tolower( ) {
       echo $* | tr '[:upper:]' '[:lower:]'
}

#---------------------------------------------------------------------
# Mainline begins here
#---------------------------------------------------------------------
#set -v
progName=$0
shortProgName=`echo $progName|sed 's/^.*\///'`
verbose=''
initialArgs="$@"

while true; do 
  case $1 in
    clone) 
      shift
      case $1 in
        -a | --all) Log "clone all!";;
        -s | --starred) Log "clone starred!";;
        -p | --personal) Log "clone personal!";;
        *) Error "$1 unrecognized clone argument";;
      esac
    ;;

    *) 
      if [ "${1}" != '' ]; then
        Error "Unknown option: '$1' Use '-h' for help"
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

#if [ x$babble = 'xTRUE' ]; then 
 # Info "babble is true"
#fi

#while true; do
       #Confirm 'Do you want to continue' 

       #Warn "This is an example of a warning"
       #Log "This is an Logment" 
       #Info "Note that the INFO lines are only printed if -v (Verbose) was set"

       #Dialog 'what is the name you want?' 
       #Log "The answer to the dialog above was: $dialogAnswer"

       #Warn "The next statement will ask for a password will be printed later.  Use a test string"
       #DialogNoEcho 'enter password (note that it is not echoed here)'
       #Log "The password was: $dialogAnswer"
#done
Info "End of Run"

#=====
USER="jfcameron"
PAGE="1"
PATH_TO_WORKSPACE=~/Workspace

# --------------
# Implementation
# --------------
function clone()
{
  pushd $PATH_TO_WORKSPACE > /dev/null
  echo "\033[1;33mCloning User Repos\033[0m"
  curl "https://api.github.com/users/$USER/repos?page=$PAGE&per_page=1" |
    grep -e 'git_url*' |
    cut -d \" -f 4 |
    xargs -L1 git clone

  echo "\033[1;33mCloning Starred Repos\033[0m"
  curl "https://api.github.com/users/$USER/starred?page=$PAGE&per_page=1" |
    grep -e 'git_url*' |
    cut -d \" -f 4 |
    xargs -L1 git clone

  popd > /dev/null
}

function fetchAndPull()
{
  print "asdf"

}

#sync