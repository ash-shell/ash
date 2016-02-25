#!/bin/bash

##################################################
# _| || |_| |   / / |   (_)         / /      | |
#|_  __  _| |  / /| |__  _ _ __    / /_ _ ___| |__
# _| || |_| | / / | '_ \| | '_ \  / / _` / __| '_ \
#|_  __  _|_|/ /  | |_) | | | | |/ / (_| \__ \ | | |
#  |_||_| (_)_/   |_.__/|_|_| |_/_/ \__,_|___/_| |_|
##################################################

# ========== Types ==========

# Booleans
Ash__TRUE="true"
Ash__FALSE="false"

# Platforms
Ash__PLATFORM_UNKNOWN='unknown'
Ash__PLATFORM_LINUX='linux'
Ash__PLATFORM_FREEBSD='freebsd'
Ash__PLATFORM_DARWIN='darwin'

# ========== Directories + Files ==========

Ash__CONFIG_FILENAME="ash_config.yaml"
Ash__MODULES_FILENAME="ash_modules.yaml"
Ash__MODULES_FOLDERNAME="ash_modules"
Ash__MODULE_CALLABLE_FILE="callable.sh"
Ash__MODULE_LIB_DIRECTORY="lib"
Ash__GLOBAL_MODULES_DIRECTORY="global_modules"
Ash__CORE_MODULES_DIRECTORY="core_modules"
Ash__MODULE_CLASSES_DIRECTORY="classes"
Ash__MODULE_ALIASES_FILE="module_aliases.yaml"
Ash__CALL_DIRECTORY="$( pwd )"
Ash__SOURCE_FILE=$(readlink ${BASH_SOURCE[0]})
Ash__SOURCE_DIRECTORY="$(dirname "$Ash__SOURCE_FILE")"
Ash__ACTIVE_MODULE_DIRECTORY="" # Determined at runtime
Ash__RC_FILE="$HOME/.ashrc"

#################################################
# Determines the active platform and wraps the
# result into an enumerated easily testable value
#################################################
Ash__get_active_platform() {
    local platform="$Ash__PLATFORM_UNKNOWN"
    local uname_string=$(uname)
    if [[ "$uname_string" == 'Linux' ]]; then
        platform="$Ash__PLATFORM_LINUX"
    elif [[ "$uname_string" == 'FreeBSD' ]]; then
        platform="$Ash__PLATFORM_FREEBSD"
    elif [[ "$uname_string" == 'Darwin' ]]; then
        platform="$Ash__PLATFORM_DARWIN"
    fi

    echo "$platform"
}

#################################################
# Imports the ashrc file, if it exists
#################################################
Ash_import_ashrc() {
    if [[ -e "$Ash__RC_FILE" ]]; then
        . "$Ash__RC_FILE"
    fi
}

#################################################
# Autoloads an entire directory, non recursive.
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
# Autoloads a modules lib directory.
# Exits if it fails to find the lib directory.
#
# @param $1: The module to load
# @param $2: 1 if we should check aliases, 0 otherwise
#       it is safe to omit this parameter if you don't
#       need to check aliases
#################################################
Ash__import() {
    local module_directory="$(Ash__find_module_directory "$1" "$2")"
    if [[ -d "$module_directory" ]]; then
        Ash_autoload "$module_directory/$Ash__MODULE_LIB_DIRECTORY"
    else
        Logger__error "Attempted to import $1 but could not find module"
        exit
    fi
}

#################################################
# Finds the module directory
#
# Checks local first, then checks global if
# there is nothing in global
#
# @param $1: The module to find
# @param $2: 1 if we should check aliases, 0 otherwise
#################################################
Ash__find_module_directory() {
    local directory=""

    # Checking Core
    local core_module_directory="$Ash__SOURCE_DIRECTORY/$Ash__CORE_MODULES_DIRECTORY"
    directory=$(Ash_find_module_directory_single "$1" "$2" "$core_module_directory")
    if [[ "$directory" != "" ]]; then
        echo "$directory"
        return
    fi

    # Checking Local
    local local_module_directory="$Ash__CALL_DIRECTORY/$Ash__MODULES_FOLDERNAME"
    directory=$(Ash_find_module_directory_single "$1" "$2" "$local_module_directory")
    if [[ "$directory" != "" ]]; then
        echo "$directory"
        return
    fi

    # Checking Global
    local global_module_directory="$Ash__SOURCE_DIRECTORY/$Ash__GLOBAL_MODULES_DIRECTORY"
    directory=$(Ash_find_module_directory_single "$1" "$2" "$global_module_directory")
    if [[ "$directory" != "" ]]; then
        echo "$directory"
        return
    fi
}

#################################################
# Attempts to find a modules directory from
# a single module location
#
# @param $1: The module to find
# @param $2: 1 if we should check aliases, 0 otherwise
# @param $3: The module directory to check in
#################################################
Ash_find_module_directory_single() {
    local module="$1"
    local check_aliases="$2"
    local module_directory="$3"

    # Checking if we should expand aliases
    if [[ "$check_aliases" -eq 1 ]]; then
        local aliases_file="$module_directory/$Ash__MODULE_ALIASES_FILE"
        if [[ -f "$aliases_file" ]]; then
            # Expanding aliases
            eval $(YamlParse__parse "$aliases_file" "Ash_alias_")

            local alias_variable="Ash_alias_$module"
            if [[ ${!alias_variable} != "" ]]; then
                module=${!alias_variable}
            fi
        fi
    fi

    # Checking if module directory exists
    local module="$module_directory/$module"
    if [[ -d $module ]]; then
        echo "$module"
        return
    fi
}

#################################################
# This function will echo 1 if $1 is a function,
# 0 otherise.
#
# @param $1: The string to test if it's a function
#################################################
Ash__is_function() {
    if [ -n "$(type -t "$1")" ] && [ "$(type -t "$1")" = function ]; then
        echo 1
    else
        echo 0
    fi
}

# ===============================================================
# ========================= Dispatch ============================
# ===============================================================

#################################################
# Loads the correct module's callable file
# to be ready to be called
#
# All callable functions will be called with
# {module}:{function_name}.  This function parses
# out both components and handles them appropriately.
#
# @params $@: All parameters passed to Ash
#################################################
Ash_dispatch() {
    local position=1
    IFS=':' read -ra segment <<< "$1"
    for part in "${segment[@]}"; do
        if [[ "$position" -eq 1 ]]; then
            Ash_load_callable_file "$part"
            Ash__import "$part" "1"
        elif [[ "$position" -eq 2 ]]; then
            Ash_execute_callable "$part" "${@:2}"
            return
        fi
        position=$((position+1))
    done

    # Can only reach here if didn't have two parts
    Ash_execute_callable "main" "${@:2}"
}

#################################################
# Loads the correct module callable file
#
# @param $1: The module name
#################################################
Ash_load_callable_file() {
    Ash__ACTIVE_MODULE_DIRECTORY="$(Ash__find_module_directory "$1" "1")"
    local callable_file="$Ash__ACTIVE_MODULE_DIRECTORY/$Ash__MODULE_CALLABLE_FILE"
    if [ -e "$callable_file" ]; then
        # Loading up callable file
        . "$callable_file"

        # Loading in config
        local config="$Ash__ACTIVE_MODULE_DIRECTORY/$Ash__CONFIG_FILENAME"
        eval $(YamlParse__parse "$config" "Ash_module_config_")

        # Setting the Obj "this" package
        Obj__import "$Ash_module_config_package" "$Obj__THIS"

        # Updating Logger's prefix
        Logger__set_prefix "$Ash_module_config_name"
    else
        Logger__error "Module '$part' is unknown"
        exit
    fi
}

#################################################
# Dispatches the proper function from the loaded
# module
#
# @param $1: The function name
# @param ${@:2} All parameters to the callable
#################################################
Ash_execute_callable() {
    # Checking if callable
    if [[ -z "$Ash_module_config_callable_prefix" ]]; then
        Logger__error "Cannot execute any callables, as 'callable_prefix' is not set in this module's ash_config.yaml"
        return
    fi

    # Executing the callable function if it exists
    local function="$Ash_module_config_callable_prefix"__callable_"$1"
    if [[ "$(Ash__is_function "$function")" -eq 1 ]]; then
        $function "${@:2}"
    else
        Logger__error "Callable '$1' is unknown"
    fi
}

#################################################
# Displays some basic help/usage for Ash
#################################################
Ash_help() {
    # TODO
    echo "Ash Help -- TODO"
    exit
}

#################################################
# Imports all of the libraries needed by
# the core to run
#################################################
Ash_import_core() {
    Ash__import "github.com/ash-shell/logger"
    Ash__import "github.com/ash-shell/yaml-parse"
    Ash__import "github.com/ash-shell/obj"
}

#################################################
# The entry point function
#################################################
Ash_start() {
    # Import ashrc file
    Ash_import_ashrc

    # Checking if user needs help
    if [[ -z "$1" || "$1" = "--help" ]]; then
        Ash_help
    fi

    # Importing the core
    Ash_import_core

    # Updating Logger prefix
    Logger__set_prefix "Ash"

    # Dispatching to module
    Ash_dispatch "$@"
}

Ash_start "$@"
