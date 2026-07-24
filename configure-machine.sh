#!/usr/bin/env bash

set -e

echo "Setting up firewall (ufw)..."
bash ./ufw.sh

echo "Generating SSH keys..."
bash ./generate-ssh-key.sh

echo "Setting git user name and email..."
bash ./git.sh

echo "Configuring commit signature..."
bash ./sign-local-commits.sh

echo "All scripts completed successfully."

