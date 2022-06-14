#!/bin/fish

if not test -d lib
  mkdir lib
end
cd lib

echo 'Cloning bling...'
git clone --depth 1 https://github.com/BlingCorp/bling 

echo 'Cloning rubato...'
git clone --depth 1 https://github.com/andOrlando/rubato

print_success "Needed lua packages installed successfully." 
