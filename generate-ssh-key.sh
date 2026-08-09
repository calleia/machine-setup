email="$1"
key_path="$HOME/.ssh/id_ed25519"

if [ -f "$key_path" ]; then
  echo "SSH key already exists at $key_path, skipping generation."
else
  ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""
fi

