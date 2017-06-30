#!/bin/bash

set -e

if [ -f /shared/hive.setup.initialised ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no completion file ###
        
        # create shared subfolder
        if [ ! -d /shared/folderstartup ]; then
           mkdir -p /shared/folderstartup
        fi
        if [ ! -d /synced/folderstartup ]; then
           mkdir -p /synced/folderstartup
        fi
        if [ -f /synced/testfile ]; then
           date >> /synced/testfile 
        else 
           echo -e "Testfile created." > /synced/testfile
        fi
        
        echo -e "Do not remove this file.\nIf you do, root password will be reset to the one in" \
                "the config" \
                "file.\n" > /shared/hive.setup.initialised
        date >> /shared/hive.setup.initialised
fi
