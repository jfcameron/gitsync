# GitSync
{IMG HERE}

## Description
Synchronize local copies of github account repos and starred repos.

Useful for maintaining a workspace across multiple machines.

## Usage
Plug in your workspace path and github account name into the config section. then refer to -h or below:

- there are three commands: clone, pull, push
- clone and pull have three arguments: --all/-a, --starred/-s, --personal/-p

- gitsync clone --all : makes local copies of all your account repos and starred repos
- gitsync pull --personal: performs git fetch --all;git pull in all personal repos in your workspace
- git push performs git add --all;git commit;git push for all personal repos in your workspace
