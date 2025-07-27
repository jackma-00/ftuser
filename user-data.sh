#!/bin/bash
yum update -y
yum install -y docker amazon-efs-utils

# Start Docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create mount point and mount EFS
mkdir -p /opt/freqtrade/user_data
mount -t efs -o tls fs-084cbf994b85d8f9e:/ /opt/freqtrade/user_data

# Add to fstab for persistent mounting
echo "fs-084cbf994b85d8f9e.efs.eu-north-1.amazonaws.com:/ /opt/freqtrade/user_data efs defaults,_netdev,tls" >> /etc/fstab

# Create log directories
mkdir -p /opt/freqtrade/user_data/logs/FirstStrategy

# Set permissions
chown -R ec2-user:ec2-user /opt/freqtrade
