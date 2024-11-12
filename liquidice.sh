#!/bin/bash

# liquidice.sh - A script to set up Icecast2, Liquidsoap (via OPAM), and Sysstat on Ubuntu

# Exit immediately if a command exits with a non-zero status
set -e

# Function to update and install necessary dependencies
install_dependencies() {
    echo "Updating package list and installing minimal dependencies..."
    sudo apt update -y && sudo apt upgrade -y
    # Install necessary build tools and libraries for OPAM installation
    sudo apt install -y build-essential m4 curl opam git pkg-config \
    libpcre3-dev libgmp-dev libssl-dev libflac-dev libvorbis-dev \
    libmad0-dev libmp3lame-dev libtag1-dev libsamplerate0-dev \
    libspeex-dev libtheora-dev libopus-dev libfdk-aac-dev alsa-utils \
    libcurl4-gnutls-dev
}

# Function to create icecast user and prompt for password
create_icecast_user() {
    echo "Creating icecast user and group..."
    sudo groupadd -f icecast
    sudo useradd -m -g icecast -s /usr/sbin/nologin icecast || echo "User icecast already exists."
    echo "Please set a password for the 'icecast' user:"
    sudo passwd icecast
}

# Function to temporarily allow icecast user to run sudo without password for apt-get
grant_sudo_privileges() {
    echo "Granting temporary passwordless sudo privileges for apt-get to icecast user..."
    echo "icecast ALL=(ALL) NOPASSWD: /usr/bin/apt-get" | sudo tee /etc/sudoers.d/icecast-apt
}

# Function to remove temporary sudo privileges
revoke_sudo_privileges() {
    echo "Revoking temporary sudo privileges from icecast user..."
    sudo rm /etc/sudoers.d/icecast-apt
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
    echo "Setting up OPAM environment and installing Liquidsoap with additional packages for the 'icecast' user..."
    
    # Switch to icecast user and initialize OPAM
    sudo -u icecast -H sh -c '
        if [ ! -d "$HOME/.opam" ]; then
            opam init --bare --yes
        fi
        eval $(opam env)
        opam update --yes
        opam switch create 4.12.0 --yes || opam switch set 4.12.0 --yes
        eval $(opam env)
        # Install Liquidsoap and recommended additional packages
        opam install liquidsoap mad lame taglib cry --yes
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

    # Step 1: Update and install minimal system dependencies
    install_dependencies

    # Step 2: Configure non-interactive installs for Icecast2
    configure_non_interactive

    # Step 3: Create the icecast user and prompt for password
    create_icecast_user

    # Step 4: Grant temporary sudo privileges for apt-get
    grant_sudo_privileges

    # Step 5: Set up the necessary directories with permissions
    setup_directories

    # Step 6: Install Liquidsoap via OPAM with additional packages
    install_liquidsoap_via_opam

    # Step 7: Revoke temporary sudo privileges
    revoke_sudo_privileges

    echo "Installation and setup complete!"
    echo "Icecast2, Liquidsoap (via OPAM), and Sysstat have been installed, including additional Liquidsoap packages."
}

# Execute the main function
main
