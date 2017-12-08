#!/bin/bash 
#!/bin/sh

#---------------------------------------------------------------------
# Configuration
#---------------------------------------------------------------------
USER="jfcameron"
PATH_TO_WORKSPACE=~/Workspace
MAX_REPOS=100

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
# $shortProgName: [ -h clone pull push ]
#       option: -h
#         print this help page
#
#       option: clone [ -a/--all, -p/--personal, -s/--starred ]
#         clone all (personal/starred/all) repos on your github
#         account using curl/github api.
#
#       option: pull [ -a/--all, -p/--personal, -s/--starred ]
#         git fetch --all;submodule update --init --recursive;git pull
#         on all (personal/starred/all) repos in workspace
#
#       option: push []
#         git add --all;git commit;git push all personal repos in 
#         workspace.
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
Print() { echo -e "$@";}

# ---------------------------------------------------------------------
# Implementation
# ---------------------------------------------------------------------
NO_STYLE='\033[0m'
REPO_STYLE='\033[38;5;3m'
UPTODATE_STYLE='\033[0;32m'
NEEDUPDATE_STYLE='\033[0;31m'

function clone()
{
  Log clone $1
  pushd $PATH_TO_WORKSPACE > /dev/null

  if [ $1 == --personal ] || [ $1 == -p ] || [ $1 == -a ] || [ $1 == --all ]; then
    Print "\033[1;33mCloning User Repos\033[0m"
    curl -u $USER "https://api.github.com/users/$USER/repos?page=1&per_page=$MAX_REPOS" |
      grep -e 'git_url*' |
      cut -d \" -f 4 |
      xargs -L1 git clone
  fi

  if [ $1 == --starred ] || [ $1 == -s ] || [ $1 == -a ] || [ $1 == --all ]; then
  Print "\033[1;33mCloning Starred Repos\033[0m"
  curl -u $USER "https://api.github.com/users/$USER/starred?page=1&per_page=$MAX_REPOS" |
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
        Print "Repo: ${REPO_STYLE}${repo}${NO_STYLE}";
        git fetch --all
        git submodule update --init --recursive
        git status
        if [[ $( git status ) != *"Your branch is up-to-date"* ]]; then
          Print "${NEEDUPDATE_STYLE}Updating...${NO_STYLE}"
          git pull
        else
          Print "${UPTODATE_STYLE}Already up-to-date.${NO_STYLE}"
        fi
        cd ..
        Print
      fi
    elif [ $1 == -s ] || [ $1 == --starred ]; then
      if [ x$isPersonalRepo == 'xFALSE' ]; then
        Print "Repo: ${REPO_STYLE}${repo}${NO_STYLE}";
        git fetch --all
        git submodule update --init --recursive
        git status
        if [[ $( git status ) != *"Your branch is up-to-date"* ]]; then
          Print "${NEEDUPDATE_STYLE}Updating...${NO_STYLE}"
          git pull
        else
          Print "${UPTODATE_STYLE}Already up-to-date.${NO_STYLE}"
        fi
        cd ..
        Print
      fi
    else
      Print "Repo: ${REPO_STYLE}${repo}${NO_STYLE}";
      git fetch --all
      git submodule update --init --recursive
      git status
      if [[ $( git status ) != *"Your branch is up-to-date"* ]]; then
        Print "${NEEDUPDATE_STYLE}Updating...${NO_STYLE}"
        git pull
      else
        Print "${UPTODATE_STYLE}Already up-to-date.${NO_STYLE}"
      fi
      cd ..
      Print
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
      Print "Repo: ${REPO_STYLE}${repo}${NO_STYLE}";
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

if [ $# == 0 ]; then
  Error "requires arguments. Use -h to display help message."
else
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
fi