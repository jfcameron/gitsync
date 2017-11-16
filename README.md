
 Written by Joseph Cameron
 Created on 2017-11-15.

 $progName -- help info 

 Summary:
 Synchronize local copies of github account repos and starred repos.
 Useful for maintaining a workspace across multiple machines.

 $shortProgName: [ -X -V -h ] otherParams
       option: -X >> turn on shell debugging (set -v) UNIMPLEMENTED
       option: -V >> verbose, turns on INFO messages UNIMPLEMENTED
       option: -h >> print this help page
       option: clone (args: -a/--all, -p/--personal, -s/--starred)
        >> clone all (personal/starred/all) repos on your github
         account using curl/github api.
       option: pull (args: -a/--all, -p/--personal, -s/--starred)
        >> git fetch --all;git pull on all (personal/starred/all) repos 
         in workspace
       option: push (args: none) >> git add --all;git commit;git push
        all personal repos in workspace.

 Example Usage:
       $shortProgName clone --all
       $shortProgName pull --personal
       $shortProgName push

