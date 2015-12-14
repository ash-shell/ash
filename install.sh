#!/bin/bash
git clone --recursive https://github.com/ash-shell/ash.git
new_location="/usr/local/ash"
mv "./ash" "$new_location"
path_location="/usr/local/bin"
cd "$path_location"
ln -s "$new_location/ash" .
echo "Ash successfully installed"
