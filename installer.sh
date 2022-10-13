#!/usr/bin/bash


# Colors
White="\033[1;37m"
Red="\033[1;31m"
Green="\033[1;32m"
Reset="\033[0m"


function show_process_msg() {
    echo -e "$White ==> $1 $Reset"
}

function show_success_msg() {
    echo -e "\n${Green}Successfully finished$Reset$White ${1}$Reset${Green}!$Reset"
}

function show_error_msg() {
    echo -e "$Red ERROR: $1 $Reset"
    if [[ ! $2 == "n" ]]; then
        exit
    fi
}


echo -e "$White

Mega.nz-Bot Installer - v1.1

"


function install_git() {
    sudo apt install git-all ||
        sudo pacman -S git ||
            sudo dnf install git ||
                show_error_msg "Your system deosn't match the current list of Oses. Please install 'git' from - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
}

function install_pip3() {
    sudo apt install python3-pip ||
        sudo pacman -S python-pip ||
            sudo dnf install python3-pip ||
                show_error_msg "Your system deosn't match the current list of Oses. Please install 'pip3' from - https://pip.pypa.io/en/stable/installation/"
}

function _aur_megatools() {
    git clone https://aur.archlinux.org/megatools.git
    cd megatools || show_error_msg "megatools dir doesn't exists rn! Tf did you do?"
    makepkg -si
    cd ..
    rm -rf megatools
}

function install_megatools() {
    sudo apt install megatools ||
        _aur_megatools ||
            sudo dnf install megatools ||
                show_error_msg "Your system deosn't match the current list of Oses. Please install 'megatools' from - https://megatools.megous.com/"
}


function checkDepends() {
    show_process_msg "Checking dependencies"

    is_git=$(command -v git &> /dev/null)
    is_ffmpeg=$(command -v ffmpeg &> /dev/null)
    is_pip3=$(command -v pip3 &> /dev/null)
    is_megatools=$(command -v megatools &> /dev/null)
    # Checks if git is installed
    if ! $is_git ; then
        show_process_msg "Installing git"
        install_git
    # Checks if ffmpeg is installed
    elif ! $is_ffmpeg ; then
        show_process_msg "Installing ffmpeg"
        curl -sS https://webinstall.dev/ffmpeg | bash ||
            show_error_msg "Ffmpeg is not installed. Visit - https://ffmpeg.org/download.html"
    # Checks if pip3 is installed
    elif ! $is_pip3 ; then
        show_process_msg "Installing pip3"
        install_pip3
    # Checks if megatools is installed
    elif ! $is_megatools ; then
        show_process_msg "Installing megatools"
        install_megatools
    fi
}


function install() {
    show_process_msg "Cloning into Mega.nz-Bot repository"
    git clone https://github.com/Itz-fork/Mega.nz-Bot || show_error_msg "Unable to clone the Mega.nz-Bot repository"

    show_process_msg "Changing the directory to 'Mega.nz-Bot'"
    cd Mega.nz-Bot || show_error_msg "'Mega.nz-Bot' folder not found"

    show_process_msg "Installing Requirements using pip3"
    pip3 install -U -r requirements.txt &> /dev/null || show_error_msg "Unable to install requirements"

    show_success_msg "Installation"
}


function genConfig() {
    show_process_msg "Generating config file"

    # Mandotory vars
    read -p "Enter your API ID: " api_id
    read -p "Enter your API HASH: " api_hash
    read -p "Enter your BOT TOKEN: " bot_token
    read -p "Enter Telegram IDs of Auth users (Seperate by a space): " auth_users
    read -p "Enter your LOG CHANNEL ID: " log_channel_id
    
    # Optional vars

    while true; do
        read -p "Do you want to make your bot public? (y/n) " is_pb
        case $is_pb in
            y|Y)
                is_public="True"
                break; shift ;;
            n|N)
                is_public="False"
                break; shift ;;
            *)
                show_error_msg "Invalid option - $is_pb !" "n"
        esac
    done

    while true; do
        read -p "Do you want to setup mega account credentials? (y/n) " is_mauth
        case $is_mauth in
            y|Y)
                read -p "Enter your Mega.nz Email: " mega_email
                read -p "Enter your Mega.nz Passsword: " mega_password
                break; shift;;
            n|N)
                break; shift ;;
            *)
                show_error_msg "Invalid option - $is_mauth !" "n";;
        esac
    done

    echo "" > config.py
    cat <<EOF >> config.py
# Copyright 2022 - Itz-fork
# Generated by Mega.nz Installer


class Config(object):
    APP_ID = $api_id
    API_HASH = "$api_hash"
    BOT_TOKEN = "$bot_token"
    AUTH_USERS = set(int(x) for x in "$auth_users".split(" "))
    IS_PUBLIC_BOT = $is_public
    LOGS_CHANNEL = $log_channel_id
    # DON'T CHANGE THESE 2 VARS
    DOWNLOAD_LOCATION = "./NexaBots"
    TG_MAX_SIZE = 2040108421
    # Mega User Account
    MEGA_EMAIL = "$mega_email"
    MEGA_PASSWORD = "$mega_password"
EOF

    show_success_msg "Generating config file"
}


function run_bot() {
    show_process_msg "Starting the bot"
    python3 -m megadl
}


function main() {
    checkDepends
    install
    genConfig
    run_bot
}

main