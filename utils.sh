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

throw_error() {
  echo -e "\x1b[1;31m====================================\x1b[0m"
  echo -e "\x1b[1;31m#  ERROR: $1  #\x1b[0m"
  echo -e "\x1b[1;31m====================================\x1b[0m"
}

option_processor() {
  read -p "Input an option [1-6 or X] and press [ENTER] to continue: " option
  if [[ $option != [1-6Xx] ]]; then
    throw_error "Invalid option entered"
    option_processor
  fi

  case $option in
  2)
    add_server
    ;;
  esac
}

add_server(){
  valid_ip=false
  private_key_found=false
  name_exists=false
  valid_username=false
  valid_port=false

  # Server name validation
  while [ "$name_exists" = false ]; do
    read -p "Enter the your server custom name: " server_name
    if [ -f ~/odogwu/servers.json ]; then
      if grep -q "$server_name" ~/odogwu/servers.json; then
        throw_error "Server name already exists"
        read -p "Enter the your server custom name: " server_name
      else
        name_exists=true
      fi
    else
      name_exists=true
    fi
  done

  # Server IP validation
  while [ "$valid_ip" = false ]; do
    read -p "Enter the server IP: " server_ip
    if [[ $server_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      valid_ip=true
    else
      throw_error "Invalid IP address"
      read -p "Enter the server IP: " server_ip
    fi
  done

  # Server username validation
  while [ "$valid_username" = false ]; do
    read -p "Enter the server username: " server_username
    if [[ $server_username =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
      valid_username=true
    else
      throw_error "Invalid username"
      read -p "Enter the server username: " server_username
    fi
  done

  
  # Server port validation (if any)
  if [ -z "$server_port" ]; then
    server_port=22
  else
    while [ "$valid_port" = false ]; do
      read -p "Enter the server port if any or press [ENTER] to skip: " server_port
      if [[ $server_port =~ ^[0-9]+$ ]] || [ -z "$server_port" ]; then
        valid_port=true
      else
        throw_error "Invalid port number"
        read -p "Enter the server port if any or press [ENTER] to skip: " server_port
      fi
    done
  fi

  # Private key validation
  while [ "$private_key_found" = false ]; do
    read -p "Enter the path to the private key file: " server_private_key

    if [ -f "$server_private_key" ]; then
      private_key_found=true
      cp "$server_private_key" ~/odogwu/"$server_name".pem
      chmod 600 ~/odogwu/"$server_name".pem
      # push the server details to the servers.json file servers array us jq
      jq --arg server_name "$server_name" --arg server_ip "$server_ip" --arg server_username "$server_username" --arg server_port "$server_port" '.servers += [{"name": $server_name, "ip": $server_ip, "username": $server_username, "port": $server_port}]' ~/odogwu/servers.json > ~/odogwu/servers.json.tmp && mv ~/odogwu/servers.json.tmp ~/odogwu/servers.json
      echo -e "\x1b[1;32m====================================\x1b[0m"
    else
    throw_error "Private key file not found"
    fi
  done




  
}