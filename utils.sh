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

show_loader_for() {
  local how_long="${1:-5}"
  (spinner $$) & LOADER_PID=$!
  sleep "$how_long"
  if [ -n "$LOADER_PID" ]; then
    kill $LOADER_PID 2>/dev/null
    wait $LOADER_PID 2>/dev/null
  fi
  printf "\b\b\b\b\b"
}

start_loader() {
  (spinner $$) & LOADER_PID=$!
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

message() {
  local message="$1"
  local status="${2:-SUCCESS}"
  local colored="green"
  local message_content="#  $status: $message  #"
  local padding=""
  local total_width=$((${#message_content}))

  for ((i = 0; i < total_width; i++)); do
    padding+="="
  done
  
  if [ "$status" = "ERROR" ]; then
    colored="red"
  fi

  echo -e $colored "$padding" "$colored" "1"
  echo -e $colored "$message_content" $colored "1"
  echo -e $colored "$padding" $colored "1"
  echo -e "\n"
}

option_processor() {
  read -p "$(colored "Input an option [1-6 or X] and press [ENTER] to continue: ")" option
  if [[ $option != [1-6Xx] ]]; then
    message "Invalid option entered" "ERROR"
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
      throw_error "No server found" "ERROR"
    fi
  else
    throw_error "No server found" "ERROR"
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
  clear
  tput rmcup

  valid_ip=false
  private_key_found=false
  name_exists=false
  valid_username=false
  valid_port=false

  echo -e "\x1b[1;32mPress $(colored '[ESC]' 'white' '3') to cancel and go back to the main menu\x1b[0m"
  while true; do
    read -s -n 1 key
    if [[ $key = $'\e' ]]; then
      clear
      cat welcome_menu.txt | sed -e 's/\(.*\)/\x1b[1;32m\1\x1b[0m/'
      echo -e "\n"
      option_processor
    fi
  done

  # Server name validation
  while [ "$name_exists" = false ]; do
    read -p "$(colored "Enter the your server custom name: " "white" "1")" server_name 
    if [ -f ~/odogwu/servers.json ]; then
      if grep -q "$server_name" ~/odogwu/servers.json; then
        throw_error "Server name already exists" "ERROR"
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
      throw_error "Invalid IP address" "ERROR"
    fi
  done

  # Server username validation
  while [ "$valid_username" = false ]; do
    read -p "Enter the server username: " server_username
    if [[ $server_username =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
      valid_username=true
    else
      throw_error "Invalid username" "ERROR"
    fi
  done

  
  # Server port validation (optional)
  while [ "$valid_port" = false ]; do
    read -p "Enter the server port if any or press [ENTER] to skip [default: $(colored "22" "blue" "3")] : " server_port
    if [[ $server_port =~ ^[0-9]+$ ]] || [ -z "$server_port" ]; then
      valid_port=true
    else
      throw_error "Invalid port number" "ERROR"
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

      start_loader

      # inform the user that the server is undergoing connection test
      # if the connection is successful, inform the user that the server has been added successfully
      # if the connection is unsuccessful, inform the user that the server has been added but the connection test failed
    else
    throw_error "Private key file not found" "ERROR"
    fi
  done
  
}
