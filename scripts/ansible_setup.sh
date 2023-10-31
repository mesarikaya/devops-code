#!/bin/bash
sudo su -

# Install Ansible
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Check if Ansible is installed and functioning
until ansible --version; do
  echo "Ansible is not yet installed or not functioning, waiting..."
  sleep 1
done
