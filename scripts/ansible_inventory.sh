#!/bin/bash

# Step 1: Get the public IP address of the Ansible instance
JENKINS_PRIVATE_IP=$(terraform output jenkins_private_ip)

IP_ADDRESSES=("$JENKINS_PRIVATE_IP") # ("ip1" "ip2" "ip3")
HOSTNAMES=("jenkins") #("hostname2" "hostname3")

# Initialize empty inventory
cat <<EOF
{
    "_meta": {
        "hostvars": {}
    },
    "all": {
        "children": []
    }
}
EOF

# Generate host entries
for ((i=0; i<${#IP_ADDRESSES[@]}; i++)); do
    IP="${IP_ADDRESSES[$i]}"
    HOST="${HOSTNAMES[$i]}"

    cat <<EOF
    "$HOST": {
        "hosts": ["$IP"],
        "vars": {}
    },
    EOF
done
