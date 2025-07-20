# 🚀 Multi-Strategy Freqtrade Setup Guide

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

#### **Step 1: Install Python and Prerequisites**

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3.12+ via Homebrew
brew install python@3.12

# Verify Python installation
python3 --version
# Should show: Python 3.12.x
```

#### **Step 2: Create Virtual Environment**

```bash
# Ensure you're in the ftuser directory (from the "Get the Project" step above)
pwd
# Should show: /path/to/ftuser

# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Verify you're in the virtual environment
which python
# Should show: /path/to/your/project/.venv/bin/python

# Upgrade pip
pip install --upgrade pip
```

#### **Step 3: Install TA-Lib (Technical Analysis Library)**

```bash
# Install TA-Lib system dependency via Homebrew
brew install ta-lib

# Verify TA-Lib system installation
brew list ta-lib

# Set environment variables for TA-Lib paths
export TA_LIBRARY_PATH=/opt/homebrew/lib
export TA_INCLUDE_PATH=/opt/homebrew/include

# Method 1: Try pre-compiled wheel first (RECOMMENDED)
pip install --find-links https://github.com/cgohlke/talib-build/releases/latest TA-Lib --prefer-binary --no-build-isolation

# If Method 1 fails, try Method 2: Force specific wheel
pip install https://github.com/cgohlke/talib-build/releases/download/v2024.10.10/TA_Lib-0.4.32-cp313-cp313-macosx_11_0_arm64.whl

# Test TA-Lib installation
python -c "import talib; import numpy as np; print('✅ TA-Lib working!'); print('SMA test:', talib.SMA(np.array([1,2,3,4,5], dtype=float), timeperiod=3))"
```

#### **Step 4: Install Freqtrade**

```bash
# Install freqtrade (method 1 - simple)
pip install freqtrade

# OR install freqtrade (method 2 - with dependencies control)
pip install freqtrade --no-deps --index-url https://pypi.org/simple/
pip install ccxt SQLAlchemy python-telegram-bot humanize cachetools requests httpx urllib3 jsonschema pandas ft-pandas-ta technical tabulate pycoingecko python-rapidjson orjson jinja2 questionary prompt-toolkit joblib rich pyarrow fastapi pydantic pyjwt websockets uvicorn psutil schedule janus ast-comments aiofiles aiohttp cryptography sdnotify python-dateutil pytz packaging freqtrade-client --index-url https://pypi.org/simple/
```

#### **Step 5: Verify Installation**

```bash
# Check freqtrade version
freqtrade --version

# Test freqtrade import
python -c "import freqtrade; print('✅ Freqtrade installation complete!')"

# Test basic functionality
freqtrade list-exchanges

# Verify TA-Lib indicators work
python -c "import talib; print('✅ TA-Lib ready for strategies!')"
```

### **🚨 Troubleshooting Python Setup**

#### **⚡ Quick Fix for TA-Lib Issues**

**If you're getting the "ld: library not found for -lta_lib" error, try this first:**

```bash
# Step 1: Set environment variables
export TA_LIBRARY_PATH=/opt/homebrew/lib
export TA_INCLUDE_PATH=/opt/homebrew/include

# Step 2: Remove and reinstall system ta-lib
brew uninstall ta-lib && brew install ta-lib

# Step 3: Use pre-compiled wheel (most reliable)
pip uninstall TA-Lib -y
pip install https://github.com/cgohlke/talib-build/releases/download/v2024.10.10/TA_Lib-0.4.32-cp313-cp313-macosx_11_0_arm64.whl

# Step 4: Test
python -c "import talib; print('✅ TA-Lib working!')"
```

**If that doesn't work, see detailed solutions below.**

---

#### **TA-Lib Installation Issues (Most Common)**

**Problem: "ld: library not found for -lta_lib" or "Cannot find ta-lib library"**

This is the most common issue on macOS ARM64. Here is the solutions:

```bash
# SOLUTION: Complete Clean Reinstall (RECOMMENDED)
# Remove any partial installation
pip uninstall TA-Lib -y

# Ensure Homebrew ta-lib is properly installed
brew uninstall ta-lib
brew install ta-lib

# Set environment variables (add to ~/.zshrc for persistence)
export TA_LIBRARY_PATH=/opt/homebrew/lib
export TA_INCLUDE_PATH=/opt/homebrew/include
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"

# Try pre-compiled wheel first
pip install --find-links https://github.com/cgohlke/talib-build/releases/latest TA-Lib --prefer-binary --no-build-isolation
```

**Verify TA-Lib Installation:**
```bash
# Test in Python
python -c "
import talib
import numpy as np
print('✅ TA-Lib version:', talib.__version__)
data = np.array([1,2,3,4,5,6,7,8,9,10], dtype=float)
sma = talib.SMA(data, timeperiod=3)
print('✅ SMA test passed:', sma)
print('✅ TA-Lib fully working!')
"
```

#### **Python Version Compatibility Issues**

**Problem: Python 3.13 compatibility issues**

```bash
# Check your Python version
python --version

# If using Python 3.13 and having issues, consider Python 3.12
brew install python@3.12

# Create new virtual environment with Python 3.12
python3.12 -m venv .venv312
source .venv312/bin/activate

# Install freqtrade with Python 3.12
pip install --upgrade pip
# Continue with TA-Lib installation from above
```

#### **Homebrew Path Issues**

**Problem: Homebrew not in correct location**

```bash
# Check Homebrew installation path
brew --prefix
# Should show /opt/homebrew on ARM64 Mac

# If different, adjust paths accordingly
export TA_LIBRARY_PATH=$(brew --prefix)/lib
export TA_INCLUDE_PATH=$(brew --prefix)/include

# Verify ta-lib is installed
ls -la $(brew --prefix)/lib/libta_lib*
ls -la $(brew --prefix)/include/ta_lib/
```

#### **Corporate Network Issues**

```bash
# Use direct PyPI if behind corporate firewall
pip install --index-url https://pypi.org/simple/ freqtrade

# For TA-Lib behind firewall
pip install --index-url https://pypi.org/simple/ --find-links https://github.com/cgohlke/talib-build/releases/latest TA-Lib --prefer-binary
```

#### **Virtual Environment Issues**

```bash
# Always verify you're in venv
echo $VIRTUAL_ENV
# Should show your venv path

# Check Python path is correct
which python
# Should show path inside your venv

# Reactivate if needed
source .venv/bin/activate

# Recreate venv if corrupted
deactivate
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
```

#### **Xcode Command Line Tools Issues**

```bash
# Ensure Xcode tools are installed (required for compilation)
xcode-select --install

# If already installed, reset
sudo xcode-select --reset

# Verify installation
xcode-select -p
# Should show: /Applications/Xcode.app/Contents/Developer or /Library/Developer/CommandLineTools
```

#### **Permission Issues**

```bash
# If you get permission errors
# DON'T use sudo pip! Instead fix permissions:

# Check pip cache permissions
ls -la ~/Library/Caches/pip/

# Clear pip cache if needed
pip cache purge

# Reinstall pip in venv
python -m pip install --upgrade pip --force-reinstall
```

#### **Final Verification Steps**

```bash
# Complete system check
echo "=== Environment Check ==="
echo "Python: $(python --version)"
echo "Pip: $(pip --version)"
echo "Virtual env: $VIRTUAL_ENV"
echo "Homebrew prefix: $(brew --prefix)"
echo "TA-Lib system lib exists: $(ls $(brew --prefix)/lib/libta_lib* 2>/dev/null && echo 'YES' || echo 'NO')"

echo "=== Testing TA-Lib ==="
python -c "
try:
    import talib
    print('✅ TA-Lib import: SUCCESS')
    print('✅ TA-Lib version:', talib.__version__)
except ImportError as e:
    print('❌ TA-Lib import: FAILED -', e)

try:
    import freqtrade
    print('✅ Freqtrade import: SUCCESS')
except ImportError as e:
    print('❌ Freqtrade import: FAILED -', e)
"
```

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

# Or install via Homebrew
brew install --cask docker

# Start Docker Desktop and complete setup
# Verify installation
docker --version
docker compose --version
```

---

## 🚀 **Launch Your Multi-Strategy Setup**

### **Start All Strategies**
```bash
# Start all containers in background
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
# Stop all running strategies
docker compose -f docker-compose-multi.yml down

# Download the latest Freqtrade image
docker compose -f docker-compose-multi.yml pull

# Start with updated images
docker compose -f docker-compose-multi.yml up -d
```

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

# Start specific container
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