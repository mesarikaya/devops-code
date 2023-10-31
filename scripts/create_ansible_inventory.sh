# Capture the Jenkins instance public IP from Terraform output
JENKINS_IP=$(terraform output jenkins_ec2_public_ip)

# Create the Ansible inventory file dynamically
echo "[jenkins]" > ansible/inventory.ini
echo "$JENKINS_IP ansible_ssh_user=ubuntu ansible_ssh_private_key_file=.private/ec2_key_pair" >> ansible/inventory.ini
