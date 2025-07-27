# 💰 AWS Cost Management Guide

Complete guide to stop/start your Freqtrade deployment to minimize costs when not actively trading.

## 📊 Cost Breakdown & Savings

| Component | Running Cost/Month | Stopped Cost/Month | Savings |
|-----------|-------------------|-------------------|---------|
| **EC2 t3.small** | $15.18 | $0.00 | **$15.18** |
| **EFS Provisioned** | $6.00 | $0.00 | **$6.00** |
| **EFS Storage** | $0.30 | $0.30 | $0.00 |
| **EBS Root Volume** | $0.80 | $0.80 | $0.00 |
| **Total** | **$22.28** | **$1.10** | **$21.18** |

**Monthly Savings: ~$21** (95% cost reduction!)

---

## 🛑 **Stop All Resources (Save Money)**

### **Step 1: Stop Trading Container**
```bash
# SSH into your instance first
ssh -i ~/.ssh/nova-key.pem ec2-user@YOUR_PUBLIC_IP

# Stop Freqtrade gracefully
cd /opt/freqtrade
sudo docker-compose down

# Verify container stopped
sudo docker ps

# Exit SSH session
exit
```

### **Step 2: Stop EC2 Instance**
```bash
# Get your instance ID (replace with your actual instance ID)
INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"

# Stop the instance
aws ec2 stop-instances --instance-ids $INSTANCE_ID

# Verify it's stopping
aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name'
```

### **Step 3: Switch EFS to Bursting Mode (Save $6/month)**
```bash
# Get your EFS ID (replace with your actual EFS ID)
EFS_ID="fs-xxxxxxxxx"

# Switch to bursting mode (eliminates provisioned throughput cost)
aws efs modify-file-system \
    --file-system-id $EFS_ID \
    --throughput-mode bursting

# Verify the change
aws efs describe-file-systems --file-system-id $EFS_ID --query 'FileSystems[0].ThroughputMode'
```

### **Step 4: Verify All Resources Stopped**
```bash
# Check EC2 status
aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name'

# Check EFS throughput mode
aws efs describe-file-systems --file-system-id $EFS_ID --query 'FileSystems[0].ThroughputMode'

echo "✅ Resources stopped - Monthly cost now ~$1.10"
```

---

## 🚀 **Start All Resources (Resume Trading)**

### **Step 1: Switch EFS Back to Provisioned**
```bash
# Switch back to provisioned throughput for better performance
aws efs modify-file-system \
    --file-system-id $EFS_ID \
    --throughput-mode provisioned \
    --provisioned-throughput-in-mibps 10

# Verify the change
aws efs describe-file-systems --file-system-id $EFS_ID --query 'FileSystems[0].ThroughputMode'
```

### **Step 2: Start EC2 Instance**
```bash
# Start the instance
aws ec2 start-instances --instance-ids $INSTANCE_ID

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get new public IP (it changes after stop/start)
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "✅ Instance started with new IP: $PUBLIC_IP"
```

### **Step 3: Update Security Group (New IP)**
```bash
# Get your current IP
NEW_IP=$(curl -s ifconfig.me)

# Get security group ID
SECURITY_GROUP_ID=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
    --output text)

# Remove old IP rules (this might fail if no old rules exist, that's ok)
aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`8080`].IpRanges[].CidrIp' \
    --output text | while read OLD_CIDR; do
    if [ "$OLD_CIDR" != "$NEW_IP/32" ]; then
        aws ec2 revoke-security-group-ingress \
            --group-id $SECURITY_GROUP_ID \
            --protocol tcp --port 8080 --cidr $OLD_CIDR 2>/dev/null || true
        aws ec2 revoke-security-group-ingress \
            --group-id $SECURITY_GROUP_ID \
            --protocol tcp --port 22 --cidr $OLD_CIDR 2>/dev/null || true
    fi
done

# Add new IP rules
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp --port 22 --cidr ${NEW_IP}/32

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp --port 8080 --cidr ${NEW_IP}/32

echo "✅ Security group updated for IP: $NEW_IP"
```

### **Step 4: Wait and Start Trading**
```bash
# Wait 2 minutes for full startup
echo "⏳ Waiting 2 minutes for full startup..."
sleep 120

# SSH into instance and start trading
ssh -i ~/.ssh/nova-key.pem ec2-user@$PUBLIC_IP << 'ENDSSH'
cd /opt/freqtrade

# Start Freqtrade
sudo docker-compose up -d

# Check status
sudo docker-compose ps

# Check logs
sudo docker-compose logs freqtrade-first

echo "🚀 Freqtrade is running!"
echo "🌐 Access UI at: http://$(curl -s ifconfig.me):8080"
ENDSSH
```

---

## 📋 **Quick Reference Scripts**

### **stop-trading.sh**
```bash
#!/bin/bash
INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"
EFS_ID="fs-xxxxxxxxx"

echo "🛑 Stopping Freqtrade deployment..."

# Stop container
ssh -i ~/.ssh/nova-key.pem ec2-user@$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text) "cd /opt/freqtrade && sudo docker-compose down"

# Stop EC2
aws ec2 stop-instances --instance-ids $INSTANCE_ID

# Switch EFS to bursting
aws efs modify-file-system --file-system-id $EFS_ID --throughput-mode bursting

echo "✅ All stopped - Monthly cost now ~$1.10"
```

### **start-trading.sh**
```bash
#!/bin/bash
INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"
EFS_ID="fs-xxxxxxxxx"

echo "🚀 Starting Freqtrade deployment..."

# Switch EFS to provisioned
aws efs modify-file-system --file-system-id $EFS_ID --throughput-mode provisioned --provisioned-throughput-in-mibps 10

# Start EC2
aws ec2 start-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get new IP and update security group
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
NEW_IP=$(curl -s ifconfig.me)
SECURITY_GROUP_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

# Update security group (simplified)
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr ${NEW_IP}/32 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 8080 --cidr ${NEW_IP}/32 2>/dev/null || true

# Wait and start container
sleep 120
ssh -i ~/.ssh/nova-key.pem ec2-user@$PUBLIC_IP "cd /opt/freqtrade && sudo docker-compose up -d"

echo "✅ Started! Access: http://$PUBLIC_IP:8080"
```

---

## 💡 **Cost Optimization Tips**

### **Weekend Trading Breaks**
- **Friday Evening**: Run stop script
- **Monday Morning**: Run start script
- **Savings**: ~$14 per weekend (if stopped Sat-Sun)

### **Monthly Trading Schedule**
- **Active Trading Days**: Keep running
- **Market Holidays**: Stop resources
- **Strategy Development**: Use local environment

### **Alternative: Spot Instances**
For advanced users, consider:
- **EC2 Spot Instances**: 60-90% cost savings
- **Risk**: Can be interrupted
- **Best for**: Testing strategies, non-critical trading

---

## 📊 **Cost Tracking**

Monitor your usage:
```bash
# Check current month costs
aws ce get-cost-and-usage \
    --time-period Start=2025-01-01,End=2025-02-01 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# Set billing alerts (one-time setup)
aws cloudwatch put-metric-alarm \
    --alarm-name "FreqtradeCostAlert" \
    --alarm-description "Alert when costs exceed $30" \
    --metric-name EstimatedCharges \
    --namespace AWS/Billing \
    --statistic Maximum \
    --period 86400 \
    --threshold 30 \
    --comparison-operator GreaterThanThreshold
```

---

## 🔒 **Data Safety**

**What's preserved when stopped:**
✅ **Trading Database**: All trades, backtests, logs  
✅ **Strategy Configurations**: All your settings  
✅ **Docker Images**: Cached locally  
✅ **EFS Data**: Permanent storage  

**What changes:**
⚠️ **Public IP Address**: Changes on each start  
⚠️ **Container State**: Needs restart  

**Your data is 100% safe** - only compute resources stop! 