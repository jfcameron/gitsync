#!/usr/bin/env bash

#---------------------------------------------------------------------
# Help & About
#---------------------------------------------------------------------
printHelp () {
sed 's/^# \{0,1\}//' << Help
#---------------------------------------------------------------------
#
# $progName -- help info 
#
# Summary:
#   Synchronize local copies of github account repos and starred repos.
#   Useful for maintaining a github workspace across multiple machines.
#
# Example Usage:
#   $shortProgName pull --personal
#   $shortProgName push
#
# $shortProgName: [ -h clone pull push status ]
#   option: -h
#     print this help page
#
#   option: clone [ -a/--all, -p/--personal, -s/--starred ]
#     clone [...] repos on your github account.
#
#   option: pull [ -a/--all, -p/--personal, -s/--starred ]
#     fetch --all;submodule update --init --recursive; pull [...]
#     repos in workspace.
#
#   option: push []
#     add --all; commit; push [personal] repos in workspace.
#
#   option: status [ -a/--all, -p/--personal, -s/--starred ]
#      status [...] repos in workspace.
#
# Config:
#   JFCAMERON_GITSYNC_USER: name of your github account.
#
#   JFCAMERON_GITSYNC_PATH_TO_WORKSPACE: 
#     path to the directory which will hold all your local copies.
#
# Author:
#   Written by Joseph Cameron | jfcameron.github.io
#   Created on 2017-11-15.
#
#---------------------------------------------------------------------
Help
}

#---------------------------------------------------------------------
# Print info, warning, or error and eit
#---------------------------------------------------------------------
Log()         { echo -e "$shortProgName:" "$@"; }
Info()        { if [ x$verbose = xTRUE ]; then echo "$shortProgName: Info:" "$@"; fi; }
Warn()        { echo -e "$shortProgName: \033[1;33mWarning:\033[0m" "$@"; }
Error()       { echo -e "$shortProgName: \033[1;31mError:\033[0m"   "$@" >/dev/stderr; exit 1; }
Print()       { echo -e "$@"; }
RequiredVar() { if [ -z ${!1+x} ]; then printHelp; Error "Required variable \"${1}\" is unset. Hint: ${2}"; fi; }

PromptForPassword() 
{
    PromptForPassword_Output=""

    trap 'stty echo; exit'  1 2 3 15
    stty -echo
    read -p "$shortProgName: " PromptForPassword_Output 
    #echo '...'
    stty echo
    trap -  1 2 3 15
    Info "DialogNoAnswer: $*: $PromptForPassword_Output"
}

#---------------------------------------------------------------------
# Configuration
#---------------------------------------------------------------------
RequiredVar "JFCAMERON_GITSYNC_USER"              "name of your github account"
RequiredVar "JFCAMERON_GITSYNC_PATH_TO_WORKSPACE" "path to the directory which will hold all your local copies"

USER=$JFCAMERON_GITSYNC_USER
PATH_TO_WORKSPACE=$JFCAMERON_GITSYNC_PATH_TO_WORKSPACE

MAX_REPOS=1000

# ---------------------------------------------------------------------
# Implementation
# ---------------------------------------------------------------------
NO_STYLE='\033[0m'
REPO_STYLE='\033[38;5;3m'
UPTODATE_STYLE='\033[0;32m'
NEEDUPDATE_STYLE='\033[0;31m'

function clone()
{
  if [ -z ${PromptForPassword_Output+x} ]; then PromptForPassword; fi

  pushd $PATH_TO_WORKSPACE > /dev/null

  if [ $1 == --personal ] || [ $1 == -p ] || [ $1 == -a ] || [ $1 == --all ]; then
    Print "\033[1;33mCloning User Repos\033[0m"
    curl -u $USER:$PromptForPassword_Output "https://api.github.com/users/$USER/repos?page=1&per_page=$MAX_REPOS" |
      grep -e 'git_url*' |
      cut -d \" -f 4 |
      xargs -L1 git clone
  fi

  if [ $1 == --starred ] || [ $1 == -s ] || [ $1 == -a ] || [ $1 == --all ]; then
  Print "\033[1;33mCloning Starred Repos\033[0m"
  curl -u $USER:$PromptForPassword_Output "https://api.github.com/users/$USER/starred?page=1&per_page=$MAX_REPOS" |
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

function status()
{
  Log "status"
  pushd $PATH_TO_WORKSPACE > /dev/null

  for repo in ./*/.git; do 
  (
    repo=${repo%.*}
    cd $repo
    
    if [ $1 == --personal ] || [ $1 == -p ] || [ $1 == -a ] || [ $1 == --all ]; then
      if [[ $(git remote get-url origin) == *"${USER}"* ]]; then
        Print "Repo: ${REPO_STYLE}${repo}${NO_STYLE}";
        git status
      fi
    fi

    if [ $1 == --starred ] || [ $1 == -s ] || [ $1 == -a ] || [ $1 == --all ]; then
      if [[ ! $(git remote get-url origin) == *"${USER}"* ]]; then
        Print "Repo: ${REPO_STYLE}${repo}${NO_STYLE}";
        git status
      fi
    fi

  ); done

  popd > /dev/null
}

#---------------------------------------------------------------------
# Mainline begins here
#---------------------------------------------------------------------
progName=$0
shortProgName=`echo $progName|sed 's/^.*\///'`
noAffixProgName=`echo $shortProgName|sed 's/\.[^.]*$//'`
verbose=''
initialArgs="$@"

if [ $# == 0 ]; then
  Error "requires arguments. Use -h to display help message."
else
  while true; do 
    case $1 in
      clone | pull | status)
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
