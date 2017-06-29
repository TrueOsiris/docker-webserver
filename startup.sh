#!/bin/bash

set -e

if [ -f /config/hive.setup.initialised ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no completion file ###
        
        # create config subfolder
        if [ ! -d /config/folderstartup]; then
           mkdir -p /config/folderstartup
        fi
        if [ ! -d /config2/folderstartup]; then
           mkdir -p /config2/folderstartup
        fi    
        
        echo -e "Do not remove this file.\nIf you do, root password will be reset to the one in" \
                "the config" \
                "file.\n" > /config/hive.setup.initialised
        date >> /config/hive.setup.initialised
fi
