#!/bin/bash

# Step 1: Initialize Terraform
terraform init

# Step 2: Format
terraform fmt

# Step 3: Validate
terraform validate

# Step 4: Apply the Terraform configuration
terraform apply -auto-approve

# Step 5: Retrieve the SSH key from AWS Secrets Manager directly and save it to a variable
#PRIVATE_KEY=$(aws secretsmanager get-secret-value --secret-id dev/ssh_private_key --query SecretString --output text | awk -F'"' '{print $4}')
#echo ${PRIVATE_KEY} > .private/private_key.pem
# Step 6: Get the public IP address of the Ansible instance
ANSIBLE_IP=$(terraform output ansible_ec2_public_ip)

# Step 7: Create a temporary private key file
#PRIVATE_KEY_FILE=$(mktemp)

# Step 8: Convert the private key format (if needed)
#echo ${PRIVATE_KEY} | ssh-keygen -p -f "$PRIVATE_KEY_FILE" -m pem -e > /dev/null 2>&1

# Step 9: Set correct permissions on the private key file
chmod 600 ".private/ec2_key_pair"

# Step 10: Transfer the Ansible playbook content using SSH
echo ".private/ec2_key_pair" | ssh -i ".private/ec2_key_pair" ubuntu@${ANSIBLE_IP//\"/} "cat > /home/ubuntu/jenkins-master-setup.yml" <<< "$(cat ansible/playbooks/jenkins-master-setup.yml)"

# Transfer Ansible Inventory file
echo ".private/ec2_key_pair" | ssh -i ".private/ec2_key_pair" ubuntu@${ANSIBLE_IP//\"/} "cat > /home/ubuntu/ansible_inventory.sh" <<< "$(cat ./scripts/ansible_inventory.sh)"

# Step 11: SSH into the Ansible instance and run the Ansible playbook using the private key file
ssh -i ".private/ec2_key_pair" ubuntu@${ANSIBLE_IP//\"/} "ansible-playbook -i /home/ubuntu/ansible_inventory.sh /home/ubuntu/jenkins-master-setup.yml"

# Step 12: Clean up (optional)
# terraform destroy -auto-approve

# Step 13: Remove the temporary private key file
rm -f "$PRIVATE_KEY_FILE"
