#!/usr/bin/env bash

set -e

read -p "Enter your name: " name
read -p "Enter your email: " email

echo "Configuring for $name <$email>"

echo "Setting up firewall (ufw)..."
bash ./ufw.sh

echo "Generating SSH keys..."
bash ./generate-ssh-key.sh "$email"

echo "Setting git user name and email..."
bash ./git.sh "$email" "$name"

echo "Configuring commit signature..."
bash ./sign-local-commits.sh

echo "All scripts completed successfully."

