#!/bin/bash

##################################################
# _| || |_| |   / / |   (_)         / /      | |
#|_  __  _| |  / /| |__  _ _ __    / /_ _ ___| |__
# _| || |_| | / / | '_ \| | '_ \  / / _` / __| '_ \
#|_  __  _|_|/ /  | |_) | | | | |/ / (_| \__ \ | | |
#  |_||_| (_)_/   |_.__/|_|_| |_/_/ \__,_|___/_| |_|
##################################################

# Constants
Ash_config_file="ash_config.yaml"
Ash_modules_file="ash_modules.yaml"
Ash_modules_folder=".ash_modules"

# Directories + files
Ash_module_bootstrap_file="bootstrap.sh"
Ash_module_lib_directory="lib"
Ash_global_modules_directory="modules"
Ash_call_directory="$( pwd )"
Ash_config_file="$Ash_call_directory/$Ash_config_file"
Ash_modules_file="$Ash_call_directory/$Ash_modules_file"
Ash_modules_directory="$Ash_call_directory/$Ash_modules_folder"
Ash_source_file=$(readlink ${BASH_SOURCE[0]})
Ash__source_directory="$(dirname "$Ash_source_file")"

#################################################
# Imports a module
#
# @param $1: The module to load
#################################################
Ash__import() {
    local module_directory="$(Ash_find_module_directory "$1")"
    if [[ -d "$module_directory" ]]; then
        Ash__autoload "$module_directory/$Ash_module_lib_directory"
    else
        Logger__error "Attempted to import $1 but could not find module"
        exit
    fi
}

#################################################
# Autoloads an entire directory, non recursive
#
# @param $1: The directory to autoload
#################################################
Ash_autoload() {
    for file in "$1"/*; do
        if [[ -f "$file" ]]; then
            . "$file"
        fi
    done
}

#################################################
# Loads the correct module
#
# @params $@: All parameters passed to Ash
#################################################
Ash_dispatch() {
    IFS=':' read -ra segment <<< "$1"
    for part in "${segment[@]}"; do
        local module_directory="$(Ash_find_module_directory "$part")"
        local bootstrap_file="$module_directory/$Ash_module_bootstrap_file"
        if [ -e "$bootstrap_file" ]; then
            . "$bootstrap_file"
        else
            Logger__error "Module $part is unknown"
        fi
        break
    done
}

#################################################
# Finds the module directory
#
# Checks local first, then checks global if
# there is nothing in global
#
# @param $1: The module to find
#################################################
Ash_find_module_directory() {
    # Checking Local
    local call_dir_module="$Ash_call_directory/$Ash_modules_folder/$1"
    if [[ -d $call_dir_module ]]; then
        echo "$call_dir_module"
        return
    fi

    # Checking Global
    local global_dir_module="$Ash__source_directory/$Ash_global_modules_directory/$1"
    if [[ -d $global_dir_module ]]; then
        echo "$global_dir_module"
        return
    fi
}

#################################################
# Displays some basic help/usage for Ash
#################################################
Ash_help() {
    # TODO
    echo "Ash Help"
    exit
}

#################################################
# The entry point function
#################################################
Ash_start() {
    # Checking if user needs help
    if [[ -z "$1" || "$1" = "--help" ]]; then
        Ash_help
    fi

    # Importing logger
    Ash__import "logger"
    Logger__prefix="Ash"

    # Dispatching to module
    Ash_dispatch "$@"
}

Ash_start "$@"
