#!/bin/bash
git clone --recursive https://github.com/BrandonRomano/ash.git
new_location="/etc/ash"
sudo mv "./ash" "$new_location"
path_location="/usr/local/bin"
cd "$path_location"
ln -s "$new_location/ash" .
echo "Ash successfully installed"
