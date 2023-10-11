#!/bin/bash

spinner() {
  local pid=$1
  local delay=0.2
  local spin='-\|/'

  while ps -p $pid > /dev/null; do
    printf " [%c] " "$spin"
    spin=${spin#?}${spin%"${spin#?}"}
    sleep $delay
    printf "\b\b\b\b\b"
  done

  printf "    \b\b\b\b\b"
}

start_loader() {
  local how_long="${1:-5}"
  (spinner $$) & LOADER_PID=$!
  sleep "$how_long"
  stop_loader
}

stop_loader() {
  if [ -n "$LOADER_PID" ]; then
    kill $LOADER_PID 2>/dev/null
    wait $LOADER_PID 2>/dev/null
  fi
  printf "\b\b\b\b\b"
}

option_processor() {
  read -p "Input an option [1-6 or X] and press [ENTER] to continue: " option
  if [[ $option != [1-6Xx] ]]; then
      echo -e "\x1b[1;31m====================================\x1b[0m"
      echo -e "\x1b[1;31m#  ERROR: Invalid Option Selected  #\x1b[0m"
      echo -e "\x1b[1;31m====================================\x1b[0m"
      option_processor
  fi
}