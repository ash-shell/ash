#!/bin/bash
script_location="/usr/local"
path_location="/usr/local/bin"
current_location="$(pwd)"

# Clone
cd "$script_location"
git clone --recursive https://github.com/ash-shell/ash.git

# Add to $PATH
cd "$path_location"
ln -s "$script_location/ash/ash" .
echo "Ash successfully installed to $script_location/ash"

# Move back
cd "$current_location"
