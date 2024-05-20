#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to ensure network anonymity using nipe
ensure_anonymity() {
    sudo nipe restart
    nipe_status=$(nipe status)
    if [[ "$nipe_status" == *"is enabled"* ]]; then
        echo "You are now connected anonymously."
        echo "Spoofed country: $(nipe status | grep 'Country' | awk '{print $2}')"
    else
        echo "Failed to ensure anonymity. Exiting..."
        exit 1
    fi
}

# Function to check network anonymity using nipe
check_anonymity() {
    if ! command_exists "nipe"; then
        echo "'nipe' is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y cpanminus
        sudo cpan install CPAN
        sudo cpan install Try::Tiny
        sudo cpan install JSON
        sudo cpan install Switch
        sudo cpan install Net::IP
        git clone https://github.com/GouveaHeitor/nipe.git
        cd nipe
        sudo cpan install .
        cd ..
        sudo rm -rf nipe
        sudo nipe install
    fi
    
    nipe_status=$(nipe status)
    if [[ "$nipe_status" == *"is enabled"* ]]; then
        echo "You are connected anonymously."
        echo "Spoofed country: $(nipe status | grep 'Country' | awk '{print $2}')"
    else
        echo "Your network connection is not anonymous. Attempting to ensure anonymity..."
        ensure_anonymity
    fi
}

# Function to install required applications
install_applications() {
    if ! command_exists "geoiplookup"; then
        echo "Installing geoip-bin..."
        sudo apt-get update
        sudo apt-get install -y geoip-bin
    fi
    if ! command_exists "tor"; then
        echo "Installing Tor..."
        sudo apt-get install -y tor
    fi
    if ! command_exists "ssh"; then
        echo "Installing SSH..."
        sudo apt-get install -y ssh
    fi
}

# Function to perform whois on remote server
perform_whois() {
    ssh "$remote_user@$remote_host" "whois $whois_address > whois_result.txt"
    scp "$remote_user@$remote_host:~/whois_result.txt" ./whois_result.txt
}

# Main script

# Step 1: Installations and Anonymity Check
install_applications
check_anonymity

# Step 2: Input remote server details and whois address
read -p "Enter remote server username: " remote_user
read -p "Enter remote server hostname or IP: " remote_host
read -p "Enter address/URL for whois: " whois_address

# Step 3: Automatically Scan the Remote Server for open ports
ssh "$remote_user@$remote_host" "echo 'Country: $(curl -s https://ipinfo.io/country)'; echo 'IP: $(curl -s https://ipinfo.io/ip)'; uptime"

# Step 4: Perform whois on remote server
perform_whois

# Step 5: Results
# Log the data collection
echo "$(date): Whois data collected from $remote_host for $whois_address" >> data_collection.log
