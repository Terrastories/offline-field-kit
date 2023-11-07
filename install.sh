#!/bin/bash
set -eu

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# Fail fast if not on Linux or Mac
OS="$(uname)"
if [[ "${OS}" == "Linux" ]]
then
  LINUX=1
elif [[ "${OS}" == "Darwin" ]]
then
  MACOS=1
else
  abort "Currently, Terrastories is only supported on macOS and Linux."
fi

# Fail fast if no internet cnonection is detected
ping -q -c1 google.com &>/dev/null && true || abort "While we can run the instance offline, an internet connection is required to complete setup."

# Set Colors & Bold
Blue='\033[0;36m'
Green='\033[0;32m'
Purple='\033[0;35m'
Off='\033[00m'
Bold='\033[1m'

## Start Helpers
shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

ohai() {
  printf "${Purple}==>${Bold} %s${Off}\n" "$(shell_join "$@")"
}

execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}
## End Helpers

# Set Up Start
echo -e "${Blue}$(
  cat <<TERRASTORIES_ASCII
_ _ _ ____ _    ____ ____ _  _ ____    ___ ____
| | | |___ |    |    |  | |\/| |___     |  |  |
|_|_| |___ |___ |___ |__| |  | |___     |  |__|
 _______ _______ ______   ______   _______ _______ _______ _______ ______   ___ _______ _______
|       |       |    _ | |    _ | |   _   |       |       |       |    _ | |   |       |       |
|_     _|    ___|   | || |   | || |  |_|  |  _____|_     _|   _   |   | || |   |    ___|  _____|
  |   | |   |___|   |_||_|   |_||_|       | |_____  |   | |  | |  |   |_||_|   |   |___| |_____
  |   | |    ___|    __  |    __  |       |_____  | |   | |  |_|  |    __  |   |    ___|_____  |
  |   | |   |___|   |  | |   |  | |   _   |_____| | |   | |       |   |  | |   |   |___ _____| |
  |___| |_______|___|  |_|___|  |_|__| |__|_______| |___| |_______|___|  |_|___|_______|_______|
 ██████  ███████ ███████ ██      ██ ███    ██ ███████ 
██    ██ ██      ██      ██      ██ ████   ██ ██      
██    ██ █████   █████   ██      ██ ██ ██  ██ █████   
██    ██ ██      ██      ██      ██ ██  ██ ██ ██      
 ██████  ██      ██      ███████ ██ ██   ████ ███████ 
                                                      
TERRASTORIES_ASCII
  )${Off}"

echo This script will guide you through setting up your offline Terrastories instance.
read -p "Press any key to start" -n 1

if ! grep -q "terrastories.local" /etc/hosts; then
  echo
  ohai Configure Your Host Domain
  read -p "$(
    cat <<MODHOSTS

We make Terrastories offline at http://terrastories.local. In order for you to
access your Terrastories instance at that URL, you will need to update your device
to map traffic from that URL to your running instance.

To do this, you must add terrastories.local to your /etc/hosts file. This requires
administrator access (sudo).

If you are comfortable with a command line, you may manually edit /etc/hosts, or
you may allow this script to automatically configure your file by supplying your
password when prompted.

Choose one:
(1) Manual
(2) Automatic

Your choice: 
MODHOSTS
  )" modHosts

  if [ $modHosts -eq 1 ]; then
    read -p "$(
  cat <<HOSTS

In a new terminal window, open /etc/hosts with appropriate write permissions
and add the following line:

127.0.0.1 terrastories.local

Press any key to continue or q to quit. 
HOSTS
    )" -n 1 k
    if [[ "$k" = "q" ]]; then
      exit
    fi
  else
    echo "Automatically configuring terrastories.local."
    sudo -- sh -c "echo '# Added by Terrastories\n127.0.0.1 terrastories.local\n# End of section' >> /etc/hosts"
    echo -e "...${Green}done!${Off}"
  fi
fi

# Boot Up
ohai Starting your Terrastories Instance

echo In the future, you can start your instance by running
echo "   docker compose up"

for i in {1..5}
do
   printf "${Purple}.${Purple}"
   sleep 1
done

docker compose up
