#!/bin/bash

# liquidice.sh - A script to set up Icecast2, Liquidsoap, and Sysstat on Ubuntu

# Exit immediately if a command exits with a non-zero status
set -e

# Function to update and install necessary dependencies
install_dependencies() {
    echo "Updating package list and installing dependencies..."
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y icecast2 liquidsoap sysstat
}

# Function to create icecast user and group
create_icecast_user() {
    echo "Creating icecast user and group..."
    sudo groupadd -f icecast
    sudo useradd -M -g icecast -s /usr/sbin/nologin icecast
}

# Function to set up /home/icecast directory with correct permissions
setup_directories() {
    echo "Setting up directories..."
    sudo mkdir -p /home/icecast
    sudo chown icecast:icecast /home/icecast
    sudo chmod 750 /home/icecast
    echo "Directory /home/icecast set with permissions for user 'icecast' and root only."
}

# Function to configure unattended install prompts
configure_non_interactive() {
    echo "Configuring non-interactive installations for Icecast2 and Liquidsoap..."
    # Pre-set answers to common prompts
    sudo debconf-set-selections <<< "icecast2 icecast2/icecast-setup boolean true"
    sudo debconf-set-selections <<< "icecast2 icecast2/hostname string localhost"
}

# Main installation and setup steps
main() {
    echo "Starting installation of Icecast2, Liquidsoap, and Sysstat..."

    # Step 1: Update and install dependencies
    install_dependencies

    # Step 2: Configure non-interactive installs for Icecast2 and Liquidsoap
    configure_non_interactive

    # Step 3: Create the icecast user and group
    create_icecast_user

    # Step 4: Set up the necessary directories with permissions
    setup_directories

    echo "Installation and setup complete!"
    echo "Icecast2, Liquidsoap, and Sysstat have been installed, and required directories and users have been set up."
}

# Execute the main function
main
