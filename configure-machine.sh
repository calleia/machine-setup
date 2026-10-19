#!/usr/bin/env bash

set -e

# Resolve this script's own directory so the helper scripts are found no
# matter which working directory it is invoked from:
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

read -p "Enter your name: " name
read -p "Enter your email: " email
read -p "Switch this repository's GitHub remotes from HTTPS to SSH? [y/N] " switch_remote

echo "Configuring for $name <$email>"

echo "Setting up firewall (ufw)..."
bash "$script_dir/ufw.sh"

echo "Generating SSH keys..."
bash "$script_dir/generate-ssh-key.sh" "$email"

echo "Setting git user name and email..."
bash "$script_dir/git.sh" "$email" "$name"

echo "Configuring commit signature..."
bash "$script_dir/sign-local-commits.sh"

if [[ "$switch_remote" =~ ^[Yy]$ ]]; then
  echo "Switching Git remotes to SSH..."
  bash "$script_dir/ssh-remote.sh" "$script_dir"
else
  echo "Keeping Git remotes unchanged."
fi

echo "All scripts completed successfully."

