#!/bin/bash

source ./utils.sh

#  Check if the odogwu directory exists
if [ ! -d ~/odogwu ] || [ ! -f ~/odogwu/servers.json ]; then
    mkdir ~/odogwu
    touch ~/odogwu/servers.json
    echo '{"servers":[]}' > ~/odogwu/servers.json
fi

clear
cat display.txt | sed -e 's/\(.*\)/\x1b[1;32m\1\x1b[0m/'

start_loader 2
echo -e "\n"
cat welcome_menu.txt | sed -e 's/\(.*\)/\x1b[1;32m\1\x1b[0m/'
echo -e "\n"

option_processor