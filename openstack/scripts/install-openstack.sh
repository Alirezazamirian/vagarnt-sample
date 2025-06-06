#!/bin/bash

useradd -s /bin/bash -d /opt/stack -m stack
chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack -i

cd /opt/stack

git clone https://opendev.org/openstack/devstack

cd devstack

cat <<'EOF' > local.conf
[[local|localrc]]
ADMIN_PASSWORD=admin2025alireza
DATABASE_PASSWORD=database2025alireza
RABBIT_PASSWORD=rabbit2025alireza
SERVICE_PASSWORD=service2025alireza
EOF

./stack.sh

