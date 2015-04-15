#!/bin/bash

##################################################
# _| || |_| |   / / |   (_)         / /      | |
#|_  __  _| |  / /| |__  _ _ __    / /_ _ ___| |__
# _| || |_| | / / | '_ \| | '_ \  / / _` / __| '_ \
#|_  __  _|_|/ /  | |_) | | | | |/ / (_| \__ \ | | |
#  |_||_| (_)_/   |_.__/|_|_| |_/_/ \__,_|___/_| |_|
##################################################

# Config
Ash__lang="en-US"
Ash_config_file="ash_config.yaml"
Ash_modules_file="ash_modules.yaml"
Ash_modules_folder=".ash_modules"

# Determining directories + files
Ash_call_directory="$( pwd )"
Ash_config_file="$Ash_call_directory/$Ash_config_file"

##################################################
#
##################################################
Ash_check_init() {
    # If we're not in a directory with a config file, exit
    if [[ ! -f "$Ash__config_file" ]]; then
        echo "$AshLang__current_directory_not_initialized"
        exit
    fi
}

##################################################
#
##################################################
Ash_load_language() {
    echo ""
}

##################################################
#
##################################################
function Ash_start() {
    echo "$Ash_lib_directory"
}

Ash_start
