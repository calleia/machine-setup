# Disable UFW:
sudo ufw disable

# Reset UFW to default (optional but recommended):
sudo ufw reset

# Deny all incoming connections:
sudo ufw default deny incoming

# Deny all outgoing connections:
sudo ufw default allow outgoing

# Allow inbound SSH from current client IP:
client_ip=${SSH_CONNECTION%% *}
sudo ufw allow from "$client_ip" to any port 22 proto tcp

# Enable UFW:
sudo ufw enable

# (Optional) Check the status:
sudo ufw status verbose

