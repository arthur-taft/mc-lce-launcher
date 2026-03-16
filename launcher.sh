#!/usr/bin/env bash

# Don't run script as root

if (( EUID == 0 )); then
    echo Script cannot be ran as root!
    exit 1
fi

EXE_DOWNLOAD="https://github.com/smartcmd/MinecraftConsoles/releases/download/nightly/Minecraft.Client.exe"
ZIP_DOWNLOAD="https://github.com/smartcmd/MinecraftConsoles/releases/download/nightly/LCEWindows64.zip"
PDB_DOWNLOAD="https://github.com/smartcmd/MinecraftConsoles/releases/download/nightly/Minecraft.Client.pdb"
INSTALL_LOCATION=${INSTALL_LOCATION:-"$HOME/games/minecraft-lce"}
COMPAT_TOOL=${COMPAT_TOOL:-"/usr/bin/wine"}
GAME_INSTALLED=${GAME_INSTALLED:-false}
LAUNCHER_LOCATION="$(pwd)"
UPDATE_NEEDED=${UPDATE_NEEDED:-false}

# Check if game is already installed

checkGameInstalled() {
    while :; do
        read -p "Do you have the game installed? (y/N): " user_game_installed
        user_game_installed=${user_game_installed:-"n"}
        if [ "${user_game_installed,,}" == "y" ] || [ "${user_game_installed,,}" == "n" ]; then
            break
        else
            echo "Response must be Y or N!"
        fi
    done

    case "$user_game_installed" in
        y)
            GAME_INSTALLED=true
            touch "$LAUNCHER_LOCATION/installed"
            ;;
        n)
            GAME_INSTALLED=false
            ;;
    esac
}

findGameInstall() {
    while :; do
        read -p "Where is the game installed? Leave blank for default (~/games/minecraft-lce): " INSTALL_LOCATION
        INSTALL_LOCATION=${INSTALL_LOCATION:-"$HOME/games/minecraft-lce"}
        read -p "Is this correct? $INSTALL_LOCATION (Y/n): " install_input_verify
        install_input_verify=${install_input_verify:-"y"}

        case "$install_input_verify" in
            y)
                break
                ;;
            n)
                continue
                ;;
            *)
                echo "Response must be Y or N!"
                ;;
        esac
    done

    # Actually verify that files are there
    
    if [ -d "$INSTALL_LOCATION" ]; then
        if [ -f "$INSTALL_LOCATION/Minecraft.Client.exe" ]; then
            touch "$LAUNCHER_LOCATION/ready"
        else 
            echo "Game executable not found!"
            exit 1
        fi
    else
        echo "Provided path does not exist"
        exit 1
    fi
}

checkForUpdates() {
    if [ -f "$LAUNCHER_LOCATION/update_check" ]; then
        checked_year=$(awk -F' ' '{print $7}' update_check)
        checked_month=$(awk -F' ' '{print $2}' update_check)
        checked_day=$(awk -F' ' '{print $3}' update_check)

        current_year=$(date | awk -F' ' '{print $7}')
        current_month=$(date | awk -F' ' '{print $2}')
        current_day=$(date | awk -F' ' '{print $3}')

        if [ "$checked_year" == "$current_year" ]; then
            if [ "$checked_month" == "$current_month" ]; then
                if [ "$checked_day" == "$current_day" ]; then
                    echo "Everything up to date!"
                else
                    date > "$LAUNCHER_LOCATION/update_check"
                    UPDATE_NEEDED=true
                fi
            else
                date > "$LAUNCHER_LOCATION/update_check"
                UPDATE_NEEDED=true
            fi
        else 
            date > "$LAUNCHER_LOCATION/update_check"
            UPDATE_NEEDED=true
        fi

    else
        date > "$LAUNCHER_LOCATION/update_check"
        UPDATE_NEEDED=true
    fi
}

installGame() {
    while :; do 
        read -p "Where do you want to install the game? Leave blank for default (~/games/minecraft-lce): " INSTALL_LOCATION
        INSTALL_LOCATION=${INSTALL_LOCATION:-"$HOME/games/minecraft-lce"}
        read -p "Is this correct? $INSTALL_LOCATION (Y/n): " install_input_verify
        install_input_verify=${install_input_verify:-"y"}

        case "$install_input_verify" in
            y)
                break
                ;;
            n)
                continue
                ;;
            *)
                echo "Response must be Y or N!"
                ;;
        esac
    done

    mkdir -p "$INSTALL_LOCATION"

    wget -O "$INSTALL_LOCATION/game.zip" "$ZIP_DOWNLOAD"

    unzip "$INSTALL_LOCATION/game.zip" -d "$INSTALL_LOCATION"

    rm "$INSTALL_LOCATION/game.zip"

    chmod +x "$INSTALL_LOCATION/Minecraft.Client.exe" "$INSTALL_LOCATION/Minecraft.Client.pch" "$INSTALL_LOCATION/Minecraft.Client.pdb"

    touch "$LAUNCHER_LOCATION/installed"
}

updateGame() {
    wget -O "$INSTALL_LOCATION/Minecraft.Client.exe" "$EXE_DOWNLOAD" 

    chmod +x "$INSTALL_LOCATION/Minecraft.Client.exe"
}

setUsername() {
    while :; do
        read -rp "What username would you like to use?: " username
        read -rp "Is this correct?: $username (Y/n): " username_verify
        username_verify=${username_verify:-"y"}
        

        case "$username_verify" in
            y)
                break
                ;;
            n)
                continue
                ;;
            *)
                echo "Response must be Y or N!"
                ;;
        esac
    done
    
    if [ -e "$INSTALL_LOCATION/username.txt" ]; then
        echo "$username" > "$INSTALL_LOCATION/username.txt"
    else
        touch "$INSTALL_LOCATION/username.txt"
        echo "$username" > "$INSTALL_LOCATION/username.txt"
    fi
}

launchGame() {
    "$COMPAT_TOOL" "$INSTALL_LOCATION/Minecraft.Client.exe" 
}

if [ -f "$LAUNCHER_LOCATION/installed" ]; then
    checkForUpdates
    updateGame
fi

while :; do
    if [ ! -f "$LAUNCHER_LOCATION/installed" ]; then 
        installGame
    elif [ ! -f "$LAUNCHER_LOCATION/ready" ]; then
        findGameInstall
    elif [ ! -f "$INSTALL_LOCATION/username.txt" ]; then
        setUsername
    else
        launchGame
        break
    fi
done
