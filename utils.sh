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
  local status_color="green"
  local message_content="#  $status: $message  #"
  local padding=""
  local total_width=$((${#message_content}))

  for ((i = 0; i < total_width; i++)); do
    padding+="="
  done
  
  if [ "$status" = "ERROR" ]; then
    status_color="red"
  fi

  echo -e "$(colored "$padding" "$status_color" "1")"
  echo -e "$(colored "$message_content" "$status_color" "1")"
  echo -e "$(colored "$padding" "$status_color" "1")"
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
      message "No server found" "ERROR"
    fi
  else
    message "No server found" "ERROR"
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


  valid_ip_or_domain=false
  private_key_found=false
  name_exists=false
  valid_username=false
  valid_port=false

  echo -e "$(colored 'Press' 'green' '0') $(colored '[ctrl + q]' 'white' '3') $(colored 'to cancel and go back to the main menu' 'green' '0')"
  echo -e "\n"

  # Server name validation
  while [ "$name_exists" = false ]; do
    read -p "$(colored "1. Enter the your server custom name: " "white" "1")" server_name 
    if [ -f ~/odogwu/servers.json ]; then
      if grep -q "$server_name" ~/odogwu/servers.json; then
        message "Server name already exists" "ERROR"
      else
        name_exists=true
      fi
    else
      name_exists=true
    fi
  done
  echo -e "\n"

  # Server IP validation
  while [ "$valid_ip_or_domain" = false ]; do
    read -p "$(colored "2. Enter the server IP or domain name: " "white" "1")" server_ip_or_domain
    if [[ $server_ip_or_domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ || $server_ip_or_domain =~ ^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,6}$ ]]; then
      valid_ip_or_domain=true
    else
      message "Invalid IP address or domain" "ERROR"
    fi
  done
  echo -e "\n"

  # Server username validation
  while [ "$valid_username" = false ]; do
    read -p "$(colored "3. Enter the server username: " "white" "1")" server_username
    if [[ $server_username =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
      valid_username=true
    else
      message "Invalid username" "ERROR"
    fi
  done
  echo -e "\n"
  
  # Server port validation (optional)
  while [ "$valid_port" = false ]; do
    read -p "$(colored "4. Enter the server port if any or press [ENTER] to skip [default: 22]: " "white" "1")" user_input
    if [ -z "$user_input" ]; then
        server_port=22
        valid_port=true
    elif [[ $user_input =~ ^[0-9]+$ ]]; then
        server_port=$user_input
        valid_port=true
    else
        message "Invalid port number" "ERROR"
    fi
  done
  echo -e "\n"

  # Private key validation
  while [ "$private_key_found" = false ]; do
    read -p "$(colored "5. Enter the path to the private key file: " "white" "1")" server_private_key

    if [ -f "$server_private_key" ]; then
      private_key_found=true
      server_pem_file_name=$(echo "$server_name" | sed 's/ //g')
      server_path_to_pem_file=~/odogwu/"$server_pem_file_name".pem
      cp "$server_private_key" "$server_path_to_pem_file"
      chmod 600 "$server_path_to_pem_file"

      clear
      start_loader
      connection_tester "$server_ip_or_domain" "$server_username" "$server_port" "$server_path_to_pem_file"

      if [ $? -eq 0 ]; then
        stop_loader
        message "Connection Successful" "SUCCESS"
        show_loader_for 3
        jq --arg name "$server_name" --arg ip_or_domain "$server_ip_or_domain" --arg username "$server_username" --arg port "$server_port" --arg pem_file_path "$server_path_to_pem_file" '.servers += [{"name": $name, "ip": $ip_or_domain, "username": $username, "port": $port, "pem_file_path": $pem_file_path}]' ~/odogwu/servers.json >~/odogwu/servers.json.tmp && mv ~/odogwu/servers.json.tmp ~/odogwu/servers.json
        show_loader_for 3
        message "Server added successfully" "SUCCESS"
        
        echo -e "\n"
        read -n 1 -s -r -p "$(colored 'Press any key to continue' 'green' '5')" && (
          clear
          cat welcome_menu.txt | sed -e 's/\(.*\)/\x1b[1;32m\1\x1b[0m/'
          echo -e "\n"
          option_processor
        )
      else
        stop_loader
        message "Connection Failed" "ERROR"
        rm "$server_path_to_pem_file"
        private_key_found=false
      fi
    else
    message "Private key file not found" "ERROR"
    fi
  done
  
}

connection_tester() {
  local server_ip="$1"
  local server_username="$2"
  local server_port="$3"
  local server_path_to_pem_file="$4"

  if ssh -i "$server_path_to_pem_file" -o StrictHostKeyChecking=no "$server_username"@"$server_ip" -p "$server_port" exit 2>/dev/null; then
    echo "SSH connection to $server_ip succeeded."
    return 0
  else
    echo "SSH connection to $server_ip failed."
    return 1
  fi
}