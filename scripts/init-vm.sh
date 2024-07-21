#!/bin/bash

# For Ubuntu VM:
# Install docker and create an user named terraform

# input ssh key for terraform user
if [ -z "$1" ]; then
  echo "Please provide the public key for the terraform user."
  exit 1
fi

# Add Docker's official GPG key:# Add 163 mirror's GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://mirrors.163.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker-163.asc
sudo chmod a+r /etc/apt/keyrings/docker-163.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker-163.asc] https://mirrors.163.com/docker-ce/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker-163.list >/dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run docker.mirror.nbtca.space/library/hello-world

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Add or ensure the terraform user can use SSH
# Step 1: Create the user if it doesn't exist
if ! id "terraform" &>/dev/null; then
  sudo useradd -m -s /bin/bash terraform
fi
sudo usermod -aG docker terraform

# Step 2: Set up SSH directory for the user
sudo mkdir -p /home/terraform/.ssh
sudo chmod 700 /home/terraform/.ssh

# Step 3: Create the authorized_keys file if it doesn't exist
sudo touch /home/terraform/.ssh/authorized_keys

# Step 4: Set permissions for authorized_keys
sudo chmod 600 /home/terraform/.ssh/authorized_keys

# Step 5: Change ownership of the .ssh directory and its contents to the terraform user
sudo chown -R terraform:terraform /home/terraform/.ssh

# Step 6: Add the public key to the authorized_keys file
echo "$1" | sudo tee -a /home/terraform/.ssh/authorized_keys

# Note: You'll need to add the public key to /home/terraform/.ssh/authorized_keys manually
# Example: sudo echo 'ssh-rsa AAA...' >> /home/terraform/.ssh/authorized_keys

# config ssh to use PubkeyAcceptedAlgorithms +ssh-rsa
# This is for docker-swarm provider
sudo sed -i 's/#PubkeyAcceptedAlgorithms PubkeyAcceptedAlgorithms/PubkeyAcceptedAlgorithms ssh-rsa/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Print completion message
echo "Docker installed and user 'terraform' added to the 'docker' group."
# Hint to add the public key to the authorized_keys file
echo "Don't forget to add the public key to /home/terraform/.ssh/authorized_keys"
