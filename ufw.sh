# Determine the client IP up front, before changing any firewall state, so we
# never end up with deny-incoming enabled and no matching SSH allow rule:
client_ip=${SSH_CONNECTION%% *}

if [ -z "$client_ip" ]; then
  echo "ERROR: SSH_CONNECTION is not set, so the client IP is unknown." >&2
  echo "Enabling UFW now would deny all incoming traffic and lock you out" >&2
  echo "of this machine. Run this over SSH, or set client_ip by hand." >&2
  exit 1
fi

# Disable UFW:
sudo ufw disable

# Reset UFW to default (optional but recommended):
sudo ufw --force reset

# Deny all incoming connections:
sudo ufw default deny incoming

# Allow all outgoing connections:
sudo ufw default allow outgoing

# Allow inbound SSH from current client IP:
sudo ufw allow from "$client_ip" to any port 22 proto tcp

# Enable UFW:
sudo ufw --force enable

# (Optional) Check the status:
sudo ufw status verbose

