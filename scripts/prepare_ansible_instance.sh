#!/bin/bash

# Access the environment variables
ANSIBLE_IP="${ANSIBLE_IP//\"/}"
JENKINS_IP="${JENKINS_IP//\"/}"
JENKINS_SLAVE_IP="${JENKINS_SLAVE_IP//\"/}"

# Debug - Print the values of environment variables
echo "ANSIBLE_IP: $ANSIBLE_IP"
echo "JENKINS_IP: $JENKINS_IP"
echo "JENKINS_SLAVE_IP: $JENKINS_SLAVE_IP"

#sudo su -

#cd /opt

# Create Ansible hosts file
cat <<EOF > hosts
[jenkins-master]
${JENKINS_IP}
[jenkins-master:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/opt/ec2_key_pair.pem

[jenkins-slave]
${JENKINS_SLAVE_IP}

[jenkins-slave:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/opt/ec2_key_pair.pem
EOF


# Transfer files to the Ansible instance
#ssh -i "hosts" ubuntu@${ANSIBLE_IP//\"/} "cat > /opt/hosts" <<< "$(cat hosts)"
#ssh -i ".private/ec2_key_pair" ubuntu@${ANSIBLE_IP//\"/} "cat > /home/ubuntu/opt/ec2_key_pair.pem" <<< "$(cat .private/ec2_key_pair)"