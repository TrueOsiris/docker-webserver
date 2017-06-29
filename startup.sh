#!/bin/bash

set -e

if [ -f /config/hive.setup.initialised ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no completion file ###
        
        # create config subfolder
        if [ ! -d /config/folder-startup]; then
           mkdir -p /config/folder-startup
        fi
        if [ ! -d /config2/folder-startup]; then
           mkdir -p /config2/folder-startup
        fi    
        
        chmod -R 775 /config/folder-startup
        chmod -R 775 /config2/folder-startup
        
        echo -e "Do not remove this file.\nIf you do, root password will be reset to the one in" \
                "the config" \
                "file.\n" > /config/hive.setup.initialised
        date >> /config/hive.setup.initialised
fi
