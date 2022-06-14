#!/bin/fish

echo 'Backing up awesome...'
if test -d ./awesome
  rm -rf ./awesome
end
cp -r ~/.config/awesome .

echo 'Backing up alacritty...'
if test -d ./alacritty
  rm -rf ./alacritty
end
cp -r ~/.config/alacritty .

echo 'Performing cleanups...'
cd awesome
rm -rf lib
mkdir lib

print_success "Config files have been backed up successfully."
