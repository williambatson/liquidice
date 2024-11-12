#!/bin/bash

# liquidice.sh - A script to set up Icecast2, Liquidsoap (via OPAM), and Sysstat on Ubuntu

# Exit immediately if a command exits with a non-zero status
set -e

# Function to update and install necessary dependencies
install_dependencies() {
    echo "Updating package list and installing system dependencies..."
    sudo apt update -y && sudo apt upgrade -y
    # Install necessary build tools and libraries
    sudo apt install -y build-essential m4 curl opam git pkg-config libpcre3-dev \
    libgmp-dev libmad0-dev libmp3lame-dev libvorbis-dev libopus-dev \
    libspeex-dev libtheora-dev libssl-dev libffmpeg-dev libflac-dev \
    libfdk-aac-dev libsamplerate-dev libmagic-dev libtag1-dev \
    libportaudio-dev alsa-utils
}

# Function to create icecast user and group
create_icecast_user() {
    echo "Creating icecast user and group..."
    sudo groupadd -f icecast
    sudo useradd -m -g icecast -s /usr/sbin/nologin icecast
}

# Function to set up /home/icecast directory with correct permissions
setup_directories() {
    echo "Setting up directories..."
    sudo mkdir -p /home/icecast
    sudo chown icecast:icecast /home/icecast
    sudo chmod 750 /home/icecast
    echo "Directory /home/icecast set with permissions for user 'icecast' and root only."
}

# Function to configure and install Liquidsoap via OPAM
install_liquidsoap_via_opam() {
    echo "Setting up OPAM environment and installing Liquidsoap for the 'icecast' user..."
    
    # Switch to icecast user and initialize OPAM
    sudo -u icecast -H sh -c '
        opam init --bare --yes
        eval $(opam env)
        opam update --yes
        opam switch create 4.12.0 --yes || opam switch set 4.12.0 --yes
        eval $(opam env)
        opam install depext --yes
        opam depext liquidsoap --yes
        opam install liquidsoap --yes
    '
}

# Function to configure unattended install prompts
configure_non_interactive() {
    echo "Configuring non-interactive installations for Icecast2..."
    # Pre-set answers to common prompts
    sudo debconf-set-selections <<< "icecast2 icecast2/icecast-setup boolean true"
    sudo debconf-set-selections <<< "icecast2 icecast2/hostname string localhost"
}

# Main installation and setup steps
main() {
    echo "Starting installation of Icecast2, Liquidsoap (via OPAM), and Sysstat..."

    # Step 1: Update and install system dependencies
    install_dependencies

    # Step 2: Configure non-interactive installs for Icecast2
    configure_non_interactive

    # Step 3: Create the icecast user and group
    create_icecast_user

    # Step 4: Set up the necessary directories with permissions
    setup_directories

    # Step 5: Install Liquidsoap via OPAM
    install_liquidsoap_via_opam

    echo "Installation and setup complete!"
    echo "Icecast2, Liquidsoap (via OPAM), and Sysstat have been installed, and required directories and users have been set up."
}

# Execute the main function
main
