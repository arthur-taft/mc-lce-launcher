#!/usr/bin/env bash

# Don't run script as root

if (( EUID == 0 )); then
    echo Script cannot be ran as root!
    exit 1
fi

EXE_DOWNLOAD="https://github.com/smartcmd/MinecraftConsoles/releases/download/nightly/Minecraft.Client.exe"
ZIP_DOWNLOAD="https://github.com/smartcmd/MinecraftConsoles/releases/download/nightly/LCEWindows64.zip"
PDB_DOWNLOAD="https://github.com/smartcmd/MinecraftConsoles/releases/download/nightly/Minecraft.Client.pdb"

# Check if game is already installed

checkGameInstalled() {
    while :; do
        read -p "Do you have the game installed? (y/N)" user_game_installed
        if [ "${user_game_installed,,}" = "y" ] || [ "${user_game_installed,,}" = "n" ]; then
            break
        else
            echo "Response must be Y or N!"
        fi
    done
    return "$user_game_installed"
}

findGameInstall() {
    while :; do
        read -p "Where is the game installed? Leave blank for default (~/games/minecraft-lce):" install_location
        read -p "Is this correct? $install_location (Y/n)" install_input_verify

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
    
    if [ -d "$install_location" ]; then
        if [ -f "$install_location/Minecraf.Client.exe" ]; then
            game_present=True
        else 
            echo "Game executable not found!"
            game_present=False
        fi
    else
        echo "Provided path does not exist"
        exit 1
    fi

    return $game_present
}

installGame() {
    while :; do 
        read -p "Where do you want to install the game? Leave blank for default (~/games/minecraft-lce):" install_location
        read -p "Is this correct? $install_location (Y/n)" install_input_verify

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

    curl "$ZIP_DOWNLOAD" -o "$install_location/game.zip"

    unzip "$install_location/game.zip" "$install_location"

    rm "$install_location/game.zip"

    chmod +x "$install_location/Minecraft.Client.exe" "$install_location/Minecraft.Client.pch" "$install_location/Minecraft.Client.pbd"
}
