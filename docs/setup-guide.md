# 🚀 Freqtrade Multi-Strategy Setup Guide

## Environment Setup to Run the Multi-Strategy Trading System

This guide will help you **set up your environment** to run the provided **three independent trading strategies**. All strategies, configurations, and Docker setups are already included - you only need to install the required software to run them. If you want to add your own strategies later, you can use this setup as a foundation and replicate the same architecture.

---

## 🎯 **What You'll Run**

### **Pre-Built Multi-Strategy Architecture**
- **3 Independent Trading Bots** (FirstStrategy, SecondStrategy, ThirdStrategy) ✅ **Already Created**
- **1 Unified Dashboard** at http://127.0.0.1:8080 ✅ **Already Configured**
- **Separate Docker Containers** for isolation and reliability ✅ **Ready to Deploy**
- **Organized Logging** and database separation ✅ **Already Set Up**
- **Professional-grade Setup** ready for dry-run testing ✅ **Complete**

---

## 📥 **Get the Project**

**First, clone the repository and navigate to the project directory:**

```bash
# Clone the ftuser repository
git clone https://github.com/jackma-00/ftuser.git

# Navigate to the project directory  
cd ftuser

# Verify you're in the correct directory
ls -la
# You should see: docs/, user_data/, docker-compose-multi.yml, README.md, etc.
```

**All subsequent commands in this guide assume you're in the `ftuser` directory.**

---

## 📋 **Prerequisites**

### **For Python Setup:**
- **macOS** (ARM64 - tested on macOS 15.5)
- **Homebrew** package manager
- **Terminal** access (default Terminal.app or iTerm2)
- **Command line** proficiency

### **For Docker Setup:**
- **macOS** (ARM64 - tested on macOS 15.5)
- **Docker Desktop** installed and running
- **Terminal** access (default Terminal.app or iTerm2)
- **Docker knowledge** for troubleshooting

### **Hardware Requirements (Both Methods)**
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space
- **Network**: Stable internet connection for market data

---

## 🐍 **Python Environment Setup**

**Set up your Python environment to run the existing multi-strategy setup:**

⚠️ **Note: All strategies, configs, and user_data are already provided. You just need to install the Python environment to run them!**

### **Install Basic Dependencies**

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required system packages (if not already installed)
brew install python@3.12 git curl wget

# Verify Python installation
python3 --version
# Should show: Python 3.12.x
```

---

## 📦 **Installation**

### **Step 1: Install TA-Lib (Essential)**

**Manual TA-Lib installation is required before installing Freqtrade:**

```bash
# Download and compile TA-Lib from source
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar xvzf ta-lib-0.4.0-src.tar.gz
cd ta-lib
sed -i.bak "s|0.00000001|0.000000000000000001 |g" src/ta_func/ta_utility.h
./configure --prefix=/usr/local
make
sudo make install
sudo ldconfig
cd ..
rm -rf ./ta-lib*
```

### **Step 2: Set Up Python Environment**

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Upgrade pip
pip install --upgrade pip
```

### **Step 3: Install Freqtrade**

```bash
# Install freqtrade via pip
pip install freqtrade

# Verify installation
freqtrade --version
python -c "import freqtrade; import talib; print('✅ Installation complete!')"
```

---

### **🎉 Python Environment Ready!**

**Your environment is now set up to run the existing multi-strategy setup!**

**Next steps (choose one):**
1. **Deploy Docker multi-strategy** (below) - Run all 3 strategies simultaneously 
2. **Validate with backtesting** - Read the [Backtesting Guide](BACKTESTING_GUIDE.md) first

---

## 🐳 **Docker Multi-Strategy Setup**

#### **Step 1: Install Docker Desktop**

```bash
# Download Docker Desktop for macOS
# Visit: https://www.docker.com/products/docker-desktop/

# Start Docker Desktop and complete setup
# Verify installation
docker --version
docker compose --version
```

---

## 🚀 **Launch Your Multi-Strategy Setup**

### **Start All Strategies**
```bash
# Create and start all containers in background
docker compose -f docker-compose-multi.yml up -d

# Verify all containers are running
docker compose -f docker-compose-multi.yml ps

# Check logs for any startup issues
docker compose -f docker-compose-multi.yml logs --tail=20
```

### **Access the Unified Interface**
1. **Open browser**: http://127.0.0.1:8080
2. **Login credentials**:
   - Username: `freqtrader`
   - Password: `SuperSecretPassword`
3. **Add other strategies** in settings:
   - SecondStrategy: http://127.0.0.1:8081
   - ThirdStrategy: http://127.0.0.1:8082

---

## ✅ **Verification Checklist**

### **System Health Check**
```bash
# 1. Container status
docker compose -f docker-compose-multi.yml ps
# Expected: 3 containers "Up"

# 2. API health
curl http://127.0.0.1:8080/api/v1/ping  # Should return {"status":"pong"}
curl http://127.0.0.1:8081/api/v1/ping  # Should return {"status":"pong"}
curl http://127.0.0.1:8082/api/v1/ping  # Should return {"status":"pong"}

# 3. Log files created
ls -la user_data/logs/*/freqtrade.log
# Expected: 3 log files with recent timestamps

# 4. Database files created
ls -la user_data/logs/*/trades.sqlite
# Expected: 3 database files

# 5. FreqUI accessibility
open http://127.0.0.1:8080
# Expected: Login page loads
```

### **Trading Activity Check**
```bash
# Wait 5-10 minutes, then check for heartbeat messages
grep "heartbeat" user_data/logs/*/freqtrade.log | tail -5

# Check for market data updates
grep -i "whitelist\|pairs" user_data/logs/*/freqtrade.log | tail -5

# Monitor live activity
tail -f user_data/logs/FirstStrategy/freqtrade.log
```

---

## 🔄 **Keeping Your System Updated**

### **Why Update Regularly**
- **Security patches** and bug fixes
- **New features** and performance improvements
- **Exchange compatibility** updates
- **Market data accuracy** improvements

### **Docker Image Updates**
```bash
# Remove all running containers (for graceful strategy shutdown, see DRY_RUN_GUIDE.md)
docker compose -f docker-compose-multi.yml down

# Download the latest Freqtrade image
docker compose -f docker-compose-multi.yml pull

# Start with updated images
docker compose -f docker-compose-multi.yml up -d
```

**⚠️ For proper graceful shutdown of active trading strategies, see [Dry Run Operations Guide](DRY_RUN_GUIDE.md) for the complete API-based shutdown procedure.**

### **Python Environment Updates**
```bash
# Activate your virtual environment
source .venv/bin/activate

# Update pip to latest version
pip install --upgrade pip

# Update Freqtrade to latest version
pip install --upgrade freqtrade

# Update TA-Lib if needed
pip install --upgrade TA-Lib

# Verify new version
freqtrade --version
```

### **Recommended Update Schedule**
- **Weekly**: Check for Docker image updates
- **Monthly**: Update Python packages and dependencies
- **Quarterly**: Review and update strategy configurations
- **Before live trading**: Always update to latest stable version

### **Update Best Practices**
- **Backup your data** before major updates
- **Test in dry-run** after updates before live trading
- **Monitor logs** for any issues after updates
- **Keep your strategies compatible** with Freqtrade API changes

---

## 🚨 **Troubleshooting Common Issues**

### **Docker Desktop Not Running**
```bash
# Error: Cannot connect to the Docker daemon
# Solution: Start Docker Desktop application
open -a Docker

# Wait for Docker to start, then retry
docker --version
```

### **Port Already in Use**
```bash
# Error: Port 8080 is already allocated
# Check what's using the port
lsof -i :8080

# Kill the process or change ports in docker-compose-multi.yml
```

### **Container Fails to Start**
```bash
# Check container logs for errors
docker logs freqtrade-first

# Common issues:
# - Invalid JSON in config files
# - Missing directories
# - Permission issues
```

### **No Trading Activity**
```bash
# Check if strategies are loading correctly
docker logs freqtrade-first | grep -i "strategy\|error"

# Verify market data is being received
docker logs freqtrade-first | grep -i "refresh\|pairs"

# Check API connectivity
docker logs freqtrade-first | grep -i "exchange\|binance"
```

---

## 🎯 **Next Steps**

### **Immediate Tasks (Day 1)**
1. **Verify Setup**: All containers running and accessible
2. **Monitor Logs**: Check for errors or unusual activity
3. **Test UI**: Navigate between different strategies
4. **Check Trading**: Look for market data updates

### **Short Term (Week 1)**
1. **Run Backtests**: Use [Backtesting Guide](BACKTESTING_GUIDE.md)
2. **Analyze Performance**: Review [Backtest Analysis](BACKTEST_ANALYSIS.md)
3. **Monitor Live**: Follow [Monitoring Guide](MONITORING_GUIDE.md)
4. **Optimize Strategies**: Adjust parameters based on results

### **Medium Term (Month 1)**
1. **Strategy Optimization**: Fine-tune based on dry-run results
2. **Risk Management**: Implement additional safety measures
3. **Performance Analysis**: Compare strategy effectiveness
4. **Consider Live Trading**: Only after thorough testing

---

## 📚 **Available Resources**

### **Complete Guide Set**
- **[Master Guide](../README.md)** - Complete overview and learning path
- **[Backtesting Guide](BACKTESTING_GUIDE.md)** - Test strategies before deploying
- **[Backtest Analysis](BACKTEST_ANALYSIS.md)** - Interpret and optimize results
- **[Unified UI Guide](UNIFIED_UI_GUIDE.md)** - Multi-strategy monitoring
- **[Monitoring Guide](MONITORING_GUIDE.md)** - Advanced monitoring and troubleshooting

### **Quick Reference Commands**
```bash
# Start all containers
docker compose -f docker-compose-multi.yml up -d

# Stop all containers
docker compose -f docker-compose-multi.yml stop

# View logs
docker compose -f docker-compose-multi.yml logs -f

# Restart specific container
docker compose -f docker-compose-multi.yml restart freqtrade-first

# Health check
curl http://127.0.0.1:8080/api/v1/ping
```

---

## ⚠️ **Important Safety Notes**

### **Dry-Run Mode**
- **All configurations are set to dry-run mode** (no real money at risk)
- **Test thoroughly** before considering live trading
- **Monitor performance** for at least 2-4 weeks

### **Risk Management**
- **Never invest more** than you can afford to lose
- **Start small** when transitioning to live trading  
- **Understand each strategy** before deploying
- **Monitor constantly** during initial deployment

### **Data & Privacy**
- **No API keys required** for dry-run mode
- **Market data is public** and anonymous
- **Local storage only** - no data sent to external services

---

**Your professional multi-strategy trading environment is ready! 🎉**

**Access your unified dashboard at: http://127.0.0.1:8080** 