# GitSync
<img src="http://jfcameron.github.io/Github/GitSync/Screenshot.png" width="100%">

## Description
Synchronize local copies of github account repos and starred repos.

Useful for maintaining a workspace across multiple machines.

## Usage
    #---------------------------------------------------------------------
    #
    # $progName -- help info 
    #
    # Summary:
    #   Synchronize local copies of github account repos and starred repos.
    #   Useful for maintaining a workspace across multiple machines.
    #
    # Example Usage:
    #   $shortProgName clone --all
    #   $shortProgName pull --personal
    #   $shortProgName push
    #
    # $shortProgName: [ -h clone pull push ]
    #   option: -h
    #     print this help page
    #
    #   option: clone [ -a/--all, -p/--personal, -s/--starred ]
    #     clone all (personal/starred/all) repos on your github
    #     account using curl/github api.
    #
    #   option: pull [ -a/--all, -p/--personal, -s/--starred ]
    #     git fetch --all;submodule update --init --recursive;git pull
    #     on all (personal/starred/all) repos in workspace
    #
    #   option: push []
    #     git add --all;git commit;git push all personal repos in 
    #     workspace.
    #
    # Author:
    #   Written by Joseph Cameron
    #   Created on 2017-11-15.
    #
    #---------------------------------------------------------------------



Plug in your workspace path and github account name into the config section. then refer to -h or below:

- there are three commands: clone, pull, push
- clone and pull have three arguments: --all/-a, --starred/-s, --personal/-p

- gitsync clone --all : makes local copies of all your account repos and starred repos
- gitsync pull --personal: performs git fetch --all;submodule update --init --recursive;git pull in all personal repos in your workspace
- git push performs git add --all;git commit;git push for all personal repos in your workspace
