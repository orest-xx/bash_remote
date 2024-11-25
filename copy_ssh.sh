#!/bin/bash

# Path to your public key
PUBLIC_KEY_PATH="~/.ssh/id_rsa.pub"

# File containing list of hosts
HOSTS_FILE="hosts.txt"

# File containing list of passwords (in the same order as hosts)
PASSWORDS_FILE="passwords.txt"

# The user to SSH as
USER="root"

# Check if hosts.txt and passwords.txt exist
if [ ! -f "$HOSTS_FILE" ]; then
  echo "Hosts file not found!"
  exit 1
fi

if [ ! -f "$PASSWORDS_FILE" ]; then
  echo "Passwords file not found!"
  exit 1
fi

# Loop through each line in the hosts.txt and passwords.txt files simultaneously
paste "$HOSTS_FILE" "$PASSWORDS_FILE" | while IFS=$'\t' read -r HOST PASSWORD; do
  echo "Copying SSH key to $USER@$HOST..."

  # Use expect to automate password entry
  /usr/bin/expect <<EOF
    spawn ssh-copy-id -i "$PUBLIC_KEY_PATH" "$USER@$HOST"
    expect "password:"
    send "$PASSWORD\r"
    expect eof
EOF

  if [ $? -eq 0 ]; then
    echo "SSH key copied successfully to $USER@$HOST."
  else
    echo "Failed to copy SSH key to $USER@$HOST."
  fi
done
