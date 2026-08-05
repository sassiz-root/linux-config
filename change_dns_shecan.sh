#!/bin/bash


#Author: (Sassiz.Root)
#Date: 2025-05-24
#This bash script is for toggle shecan.ir dns

#Display Ascii Art Banner
cat << EOF
+----------------------------------------------+
|                                              |
|          Shecan.ir DNS Toggle                |
|                                              |
|          Author: Sassiz.Root                 |
|          	                               |
|          Thanks Shecan.ir                    |
|                                              |
+----------------------------------------------+
EOF

echo "[info]: This script has 2 switches, on/off for disable or enable shecan.ir dns"
echo "[info]: This script change dns temprory! for persist edit NetworkManager config file!"
echo "[info]: For persistance /etc/resolv.conf run this command: sudo nano /etc/NetworkManager/conf.d/90-dns-none.conf"
echo "[info]: Add this line: dns=none"
echo "[info]: Then restart Netwrokmanager with this command: sudo systemctl restart NetworkManager"


# Function to print messages
print_message() {
    echo "[INFO] $1"
}

# Function to print errors and exit
print_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Check if script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)."
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    print_error "curl is not installed. Please install it using 'sudo apt install curl'."
fi

# Check if an argument is provided
if [ $# -ne 1 ]; then
    print_error "Usage: $0 {on|off}"
fi

# Check if the argument is valid
if [ "$1" != "on" ] && [ "$1" != "off" ]; then
    print_error "Invalid argument. Use 'on' or 'off'."
fi

# Define the resolv.conf file
RESOLV_CONF="/etc/resolv.conf"

# Check if resolv.conf exists
if [ ! -f "$RESOLV_CONF" ]; then
    print_error "File $RESOLV_CONF does not exist."
fi

# Function to backup resolv.conf
backup_resolv_conf() {
    local backup_file="$RESOLV_CONF.bak_$(date +%F_%H-%M-%S)"
    print_message "Creating backup of $RESOLV_CONF to $backup_file"
    cp "$RESOLV_CONF" "$backup_file" || print_error "Failed to create backup of $RESOLV_CONF"
}

# Function to extract Shecan DNS IPs
extract_shecan_ips() {
    print_message "Fetching Shecan DNS IPs from https://shecan.ir/"
    SHECAN_IPS=$(curl -s https://shecan.ir/ | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 2)

    if [ $(echo "$SHECAN_IPS" | wc -l) -ne 2 ]; then
        print_error "Failed to extract exactly two DNS IPs from Shecan website."
    fi

    print_message "Extracted Shecan DNS IPs: $SHECAN_IPS"
}

# Function to handle 'on' switch
handle_on() {
    backup_resolv_conf

    print_message "Commenting out existing nameserver entries in $RESOLV_CONF"
    sed -i '/^[[:space:]]*nameserver/ s/^/#/' "$RESOLV_CONF" || print_error "Failed to comment out existing nameservers"

    print_message "Adding Shecan DNS IPs to $RESOLV_CONF"
    for ip in $SHECAN_IPS; do
        echo "nameserver $ip" >> "$RESOLV_CONF" || print_error "Failed to add nameserver $ip to $RESOLV_CONF"
        print_message "Added nameserver $ip"
    done

    print_message "Successfully configured Shecan DNS in $RESOLV_CONF"
    print_message "Current $RESOLV_CONF content:"
    cat "$RESOLV_CONF"
}

# Function to handle 'off' switch
handle_off() {
    backup_resolv_conf

    # Hardcode Shecan IPs for 'off' mode
    SHECAN_IPS="178.22.122.100 185.51.200.2"
    print_message "Using Shecan DNS IPs for 'off' mode: $SHECAN_IPS"

    print_message "Removing Shecan DNS IPs from $RESOLV_CONF"
    for ip in $SHECAN_IPS; do
        if grep -E "^[[:space:]]*nameserver[[:space:]]+$ip" "$RESOLV_CONF" > /dev/null; then
            sed -i "/^[[:space:]]*nameserver[[:space:]]\+$ip/d" "$RESOLV_CONF" || print_error "Failed to remove nameserver $ip"
            print_message "Removed nameserver $ip"
        else
            print_message "Nameserver $ip not found in $RESOLV_CONF"
        fi
    done

    print_message "Uncommenting other nameserver entries in $RESOLV_CONF"
    sed -i '/^[[:space:]]*#nameserver[[:space:]]\+[^#]/ s/^#//' "$RESOLV_CONF" || print_error "Failed to uncomment other nameservers"

    print_message "Successfully restored original DNS settings in $RESOLV_CONF"
    print_message "Current $RESOLV_CONF content:"
    cat "$RESOLV_CONF"
}

# Main logic
case "$1" in
    "on")
        extract_shecan_ips
        handle_on
        ;;
    "off")
        handle_off
        ;;
esac

print_message "Script execution completed."
