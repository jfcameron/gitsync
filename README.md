# GitSync
<img src="http://jfcameron.github.io/Github/GitSync/Screenshot.png" width="100%">

## Description
Synchronize local copies of github account repos and starred repos.

Useful for maintaining a workspace across multiple machines.

## Usage
Set the following variables in your bash profile:

    export JFCAMERON_GITSYNC_USER="jfcameron"
    export JFCAMERON_GITSYNC_PATH_TO_WORKSPACE="~/Workspace"

then refer to gitsync.sh -h:

    #---------------------------------------------------------------------
    #
    # gitsync.sh -- help info 
    #
    # Summary:
    #   Synchronize local copies of github account repos and starred repos.
    #   Useful for maintaining a github workspace across multiple machines.
    # 
    # Example Usage:
    #   gitsync.sh pull --personal
    #   gitsync.sh push
    # 
    # gitsync.sh: [ -h clone pull push status ]
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
    #   Written by Joseph Cameron
    #   Created on 2017-11-15.
    # 
    #---------------------------------------------------------------------

consider adding gitsync to your path for the most convenience.
