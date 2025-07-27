# 🚀 AWS EC2 + EFS Deployment Guide

Complete step-by-step guide to deploy Freqtrade on AWS EC2 with EFS persistent storage.

## 📋 Overview

This guide sets up:
- **Single EC2 Instance**: t3.small for cost-effective trading
- **EFS File System**: Persistent storage for SQLite databases and logs
- **Security Group**: Minimal access (SSH + Freqtrade UI)
- **Docker Compose**: Single strategy container management

**Estimated Monthly Cost**: ~$22 USD  
**Setup Time**: ~10 minutes  
**Prerequisites**: AWS CLI configured with appropriate permissions

---

## 🏗️ Step-by-Step Infrastructure Setup

### **Step 1: Set Up AWS CLI & Variables**

```bash
# Set your AWS region and availability zone
export AWS_REGION="us-east-1"
export AWS_AZ="us-east-1a"
export KEY_PAIR_NAME="nova-key"
export PROJECT_NAME="nova"
```

### **Step 2: Create Key Pair for SSH Access**

```bash
# Create new key pair
aws ec2 create-key-pair \
    --key-name $KEY_PAIR_NAME \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/${KEY_PAIR_NAME}.pem

# Set proper permissions
chmod 400 ~/.ssh/${KEY_PAIR_NAME}.pem

echo "✅ SSH key created: ~/.ssh/${KEY_PAIR_NAME}.pem"
```

### **Step 3: Create Security Group**

```bash
# Get default VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text)

# Create security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name ${PROJECT_NAME}-sg \
    --description "Freqtrade Security Group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

# Get your public IP
MY_IP=$(curl -s ifconfig.me)

# Add SSH access (your IP only)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 22 \
    --cidr ${MY_IP}/32

# Add Freqtrade UI access (your IP only)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 8080 \
    --cidr ${MY_IP}/32

# Add NFS access for EFS (within VPC)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 2049 \
    --source-group $SECURITY_GROUP_ID

echo "✅ Security Group created: $SECURITY_GROUP_ID"
echo "✅ Access granted to your IP: $MY_IP"
```

### **Step 4: Create EFS File System**

```bash
# Create EFS file system
EFS_ID=$(aws efs create-file-system \
    --performance-mode generalPurpose \
    --throughput-mode provisioned \
    --provisioned-throughput-in-mibps 10 \
    --tags Key=Name,Value=${PROJECT_NAME}-data \
    --query 'FileSystemId' --output text)

# Get default subnet
SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=availability-zone,Values=$AWS_AZ" \
    --query 'Subnets[0].SubnetId' --output text)

# Create mount target
aws efs create-mount-target \
    --file-system-id $EFS_ID \
    --subnet-id $SUBNET_ID \
    --security-groups $SECURITY_GROUP_ID

echo "✅ EFS created: $EFS_ID"
echo "✅ Mount target created in subnet: $SUBNET_ID"
```

### **Step 5: Create User Data Script**

```bash
# Create the user data script
cat > user-data.sh << EOF
#!/bin/bash
yum update -y
yum install -y docker amazon-efs-utils

# Start Docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create symlink so docker-compose works without full path
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Create mount point and mount EFS
mkdir -p /opt/freqtrade/user_data
mount -t efs -o tls $EFS_ID:/ /opt/freqtrade/user_data

# Add to fstab for persistent mounting
echo "$EFS_ID.efs.$AWS_REGION.amazonaws.com:/ /opt/freqtrade/user_data efs defaults,_netdev,tls" >> /etc/fstab

# Create log directories
mkdir -p /opt/freqtrade/user_data/logs/FirstStrategy

# Set permissions
chown -R ec2-user:ec2-user /opt/freqtrade
EOF

echo "✅ User data script created"
```

### **Step 6: Launch EC2 Instance**

```bash
# Get Amazon Linux 2 AMI ID
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text)

# Launch instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t3.small \
    --key-name $KEY_PAIR_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --user-data file://user-data.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${PROJECT_NAME}-trader}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "✅ EC2 Instance launched: $INSTANCE_ID"
echo "⏳ Waiting for instance to be running..."

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "✅ Instance is running!"
echo "🌐 Public IP: $PUBLIC_IP"
```

### **Step 7: Prepare Docker Compose for AWS**

Create AWS-specific docker-compose file:

```bash
# Create docker-compose-aws.yml
cat > docker-compose-aws.yml << EOF
---
services:
  freqtrade-first:
    image: freqtradeorg/freqtrade:stable
    restart: unless-stopped
    container_name: freqtrade-first
    volumes:
      - "/opt/freqtrade/user_data:/freqtrade/user_data"
    ports:
      - "8080:8080"  # Remove localhost binding for AWS
    command: >
      trade
      --logfile /freqtrade/user_data/logs/FirstStrategy/freqtrade.log
      --db-url sqlite:////freqtrade/user_data/logs/FirstStrategy/trades.sqlite
      --config /freqtrade/user_data/strategies/FirstStrategy/config_dryrun.json
      --strategy FirstStrategy
      --strategy-path /freqtrade/user_data/strategies/FirstStrategy
EOF

echo "✅ AWS Docker Compose file created"
```

### **Step 8: Wait for Instance Setup and Upload Files**

```bash
echo "⏳ Waiting 3 minutes for user-data script to complete..."
sleep 180

# Test SSH connection
echo "🔑 Testing SSH connection..."
ssh -i ~/.ssh/${KEY_PAIR_NAME}.pem -o ConnectTimeout=10 ec2-user@$PUBLIC_IP "echo 'SSH connection successful!'"

# Upload your strategy files
echo "📁 Uploading strategy files..."
scp -i ~/.ssh/${KEY_PAIR_NAME}.pem -r user_data/strategies/ ec2-user@$PUBLIC_IP:/opt/freqtrade/user_data/

# Upload the AWS docker-compose file
scp -i ~/.ssh/${KEY_PAIR_NAME}.pem docker-compose-aws.yml ec2-user@$PUBLIC_IP:/opt/freqtrade/docker-compose.yml

echo "✅ Files uploaded successfully!"
```

### **Step 9: Start Your Freqtrade Container**

```bash
# SSH into instance and start container
ssh -i ~/.ssh/${KEY_PAIR_NAME}.pem ec2-user@$PUBLIC_IP << 'ENDSSH'
cd /opt/freqtrade

# Start the container
sudo docker-compose up -d

# Check status
sudo docker-compose ps

# View logs
sudo docker-compose logs freqtrade-first

echo "🚀 Freqtrade is now running!"
echo "🌐 Access UI at: http://$(curl -s ifconfig.me):8080"
ENDSSH
```

### **Step 10: Verify Everything Works**

```bash
echo "🔍 Final verification..."

# Check if container is running
ssh -i ~/.ssh/${KEY_PAIR_NAME}.pem ec2-user@$PUBLIC_IP "sudo docker ps"

# Check EFS mount
ssh -i ~/.ssh/${KEY_PAIR_NAME}.pem ec2-user@$PUBLIC_IP "df -h | grep efs"

# Display access information
echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Freqtrade UI: http://$PUBLIC_IP:8080"
echo "🔑 SSH Access: ssh -i ~/.ssh/${KEY_PAIR_NAME}.pem ec2-user@$PUBLIC_IP"
echo "📁 Data Location: /opt/freqtrade/user_data (EFS mounted)"
echo "🐳 Container: freqtrade-first"
echo "💾 Database: /opt/freqtrade/user_data/logs/FirstStrategy/trades.sqlite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## 🎮 Container Management Commands

### **Connect to Instance**
```bash
ssh -i ~/.ssh/nova-key.pem ec2-user@YOUR_PUBLIC_IP
```

### **Container Operations**
```bash
# View container status
sudo docker-compose ps

# View live logs
sudo docker-compose logs -f freqtrade-first

# Restart container
sudo docker-compose restart freqtrade-first

# Stop all containers
sudo docker-compose down

# Start all containers
sudo docker-compose up -d

# Update to latest Freqtrade version
sudo docker-compose pull
sudo docker-compose up -d
```

### **Data Management**
```bash
# Check EFS mount
df -h | grep efs

# View database files
ls -la /opt/freqtrade/user_data/logs/FirstStrategy/

# Check strategy files
ls -la /opt/freqtrade/user_data/strategies/FirstStrategy/

# View recent logs
tail -f /opt/freqtrade/user_data/logs/FirstStrategy/freqtrade.log
```

---

## 💰 Cost Breakdown

| Component | Specification | Monthly Cost (USD) |
|-----------|---------------|-------------------|
| **EC2 t3.small** | 2 vCPUs, 2GB RAM | $15.18 |
| **EFS Standard** | 1GB storage | $0.30 |
| **EFS Throughput** | 10 MiB/s provisioned | $6.00 |
| **EBS Root Volume** | 8GB gp3 | $0.80 |
| **Data Transfer** | Minimal usage | $0.10 |
| **Total** | | **~$22.38** |

---

## 🛡️ Security Features

- **SSH Access**: Restricted to your IP address only
- **Freqtrade UI**: Accessible only from your IP address
- **EFS Mount**: Secured within VPC, no internet access
- **API Authentication**: Username/password protected
- **Auto-restart**: Containers restart automatically on failure

---

## 📊 System Requirements Met

✅ **Single Container Strategy**: Runs FirstStrategy independently  
✅ **Persistent Database**: SQLite on EFS survives instance restarts  
✅ **Minimal Cost**: No load balancing, autoscaling, or unnecessary services  
✅ **24/7 Operation**: Auto-restart ensures continuous trading  
✅ **Remote Access**: SSH and web UI access from anywhere  
✅ **Data Safety**: EFS provides redundant, persistent storage  

---

## 📝 Important Notes

1. **IP Address Changes**: If your public IP changes, update the security group rules
2. **Strategy Updates**: Upload new strategy files via SCP and restart containers
3. **Backups**: EFS automatically handles data redundancy
4. **Monitoring**: Access logs via SSH or Freqtrade UI
5. **Scaling**: Add more strategies by updating docker-compose.yml

---

## 🔧 Troubleshooting

### **Docker-Compose Command Not Found**
If you encounter `docker-compose: command not found`, the PATH fix wasn't applied:
```bash
# Quick fix - create symlink
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify it works
docker-compose --version
```

For troubleshooting and advanced configurations, refer to the main Freqtrade documentation.

For **cost optimization** when not actively trading, see: [AWS Cost Management Guide](AWS_COST_MANAGEMENT.md) 