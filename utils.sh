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

colored() {
  local text="$1"
  local color="${2:-green}"
  local effect="${3:-0}"
  
  case $color in
  red)
    echo -e "\x1b[$effect;31m$text\x1b[0m"
    ;;
  green)
    echo -e "\x1b[$effect;32m$text\x1b[0m"
    ;;
  blue)
    echo -e "\x1b[$effect;34m$text\x1b[0m"
    ;;
  white)
    echo -e "\x1b[$effect;37m$text\x1b[0m"
    ;;
  yellow)
    echo -e "\x1b[$effect;33m$text\x1b[0m"
    ;;
  magenta)
    echo -e "\x1b[$effect;35m$text\x1b[0m"
    ;;
  cyan)
    echo -e "\x1b[$effect;36m$text\x1b[0m"
    ;;
  esac
}

throw_error() {
  local message="$1"
  local error_message="#  ERROR: $message  #"
  local padding=""
  local total_width=$((${#error_message}))

  for ((i = 0; i < total_width; i++)); do
    padding+="="
  done

  echo -e $colored "$padding" "red" "1"
  echo -e $colored "$error_message" "red" "1"
  echo -e $colored "$padding" "red" "1"
  echo -e "\n"
}

option_processor() {
  read -p "$(colored "Input an option [1-6 or X] and press [ENTER] to continue: ")" option
  if [[ $option != [1-6Xx] ]]; then
    throw_error "Invalid option entered"
    option_processor
  fi

  case $option in
  1)
    list_server
    ;;
  2)
    add_server
    ;;
  esac
}


list_server() {
  clear
  tput rmcup

  echo -e "\x1b[1;32mPress $(colored '[ESC]' 'white' '3') to go back to the main menu\x1b[0m"
  if [ -f ~/odogwu/servers.json ]; then
    if [ "$(jq '.servers | length' ~/odogwu/servers.json)" -gt 0 ]; then
      echo -e "\x1b[1;32m====================================\x1b[0m"
      jq -r '.servers | to_entries | .[] | "\(.key + 1). \(.value.name)"' ~/odogwu/servers.json
      echo -e "\x1b[1;32m====================================\x1b[0m"
    else
      throw_error "No server found"
    fi
  else
    throw_error "No server found"
  fi

  while true; do
    read -s -n 1 key
    if [[ $key = $'\e' ]]; then
      clear
      cat welcome_menu.txt | sed -e 's/\(.*\)/\x1b[1;32m\1\x1b[0m/'
      echo -e "\n"
      option_processor
    fi
  done

}

add_server(){
  valid_ip=false
  private_key_found=false
  name_exists=false
  valid_username=false
  valid_port=false

  # Server name validation
  while [ "$name_exists" = false ]; do
    read -p $(colored "Enter the your server custom name: " "white" "1") server_name 
    if [ -f ~/odogwu/servers.json ]; then
      if grep -q "$server_name" ~/odogwu/servers.json; then
        throw_error "Server name already exists"
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
    fi
  done

  # Server username validation
  while [ "$valid_username" = false ]; do
    read -p "Enter the server username: " server_username
    if [[ $server_username =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
      valid_username=true
    else
      throw_error "Invalid username"
    fi
  done

  
  # Server port validation (optional)
  while [ "$valid_port" = false ]; do
    read -p "Enter the server port if any or press [ENTER] to skip [default: 22] : " server_port
    if [[ $server_port =~ ^[0-9]+$ ]] || [ -z "$server_port" ]; then
      valid_port=true
    else
      throw_error "Invalid port number"
    fi
  done

  # Private key validation
  while [ "$private_key_found" = false ]; do
    read -p "Enter the path to the private key file: " server_private_key

    if [ -f "$server_private_key" ]; then
      private_key_found=true
      server_pem_file_name=$(echo "$server_name" | sed 's/ //g')
      server_path_to_pem_file=~/odogwu/"$server_pem_file_name".pem
      cp "$server_private_key" "$server_path_to_pem_file"
      chmod 600 "$server_path_to_pem_file"
      jq --arg name "$server_name" --arg ip "$server_ip" --arg username "$server_username" --arg port "$server_port" --arg pem_file_path "$server_path_to_pem_file" '.servers += [{"name": $name, "ip": $ip, "username": $username, "port": $port, "pem_file_path": $pem_file_path}]' ~/odogwu/servers.json >~/odogwu/servers.json.tmp && mv ~/odogwu/servers.json.tmp ~/odogwu/servers.json

      echo -e "\x1b[1;32m====================================\x1b[0m"
    else
    throw_error "Private key file not found"
    fi
  done
  
}