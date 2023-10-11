#!/bin/bash

source ./utils.sh

clear
cat display.txt | sed -e 's/\(.*\)/\x1b[1;32m\1\x1b[0m/'

start_loader 10

clear
cat welcome_menu.txt | sed -e 's/\(.*\)/\x1b[1;32m\1\x1b[0m/'
echo -e "\n"

option_processor