#!/bin/bash 
#!/bin/sh

#---------------------------------------------------------------------
# Configuration
#---------------------------------------------------------------------
USER="jfcameron"
PATH_TO_WORKSPACE=~/Workspace

#---------------------------------------------------------------------
# Help & About
#---------------------------------------------------------------------
printHelp () {
sed 's/^# \{0,1\}//' << Help
#---------------------------------------------------------------------
# Written by Joseph Cameron
# Created on 2017-11-15.
#
# $progName -- help info 
#
# Summary:
# Synchronize local copies of github account repos and starred repos.
# Useful for maintaining a workspace across multiple machines.
#
# $shortProgName: [ -X -V -h ] otherParams
#       option: -X >> turn on shell debugging (set -v) UNIMPLEMENTED
#       option: -V >> verbose, turns on INFO messages UNIMPLEMENTED
#       option: -h >> print this help page
#       option: clone (args: -a/--all, -p/--personal, -s/--starred)
#        >> clone all (personal/starred/all) repos on your github
#         account using curl/github api.
#       option: pull (args: -a/--all, -p/--personal, -s/--starred)
#        >> git fetch --all;git pull on all (personal/starred/all) repos 
#         in workspace
#       option: push (args: none) >> git add --all;git commit;git push
#        all personal repos in workspace.
#
# Example Usage:
#       $shortProgName clone --all
#       $shortProgName pull --personal
#       $shortProgName push
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
    cd $repo

    if [[ $(git remote get-url origin) == *"${USER}"* ]]; then
      isPersonalRepo=TRUE
    else
      isPersonalRepo=FALSE
    fi

    if [ $1 == -p ] || [ $1 == --personal ]; then
      if [ x$isPersonalRepo == 'xTRUE' ]; then
        printf "Repo: ${REPO_STYLE}${repo}${NO_STYLE}\n";
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
      fi
    elif [ $1 == -s ] || [ $1 == --starred ]; then
      if [ x$isPersonalRepo == 'xFALSE' ]; then
        printf "Repo: ${REPO_STYLE}${repo}${NO_STYLE}\n";
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
      fi
    else
      printf "Repo: ${REPO_STYLE}${repo}${NO_STYLE}\n";
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
    fi

  ); done

  popd > /dev/null
}

function push()
{
  Log "push"
  pushd $PATH_TO_WORKSPACE > /dev/null

  for repo in ./*/.git; do 
  (
    repo=${repo%.*}
    cd $repo

    if [[ $(git remote get-url origin) == *"${USER}"* ]]; then
      git add --all
      git commit
      git push
    fi

  ); done

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
