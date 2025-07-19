# 🚀 Multi-Strategy Freqtrade Setup Guide

## Environment Setup to Run the Multi-Strategy Trading System

This guide will help you **set up your environment** to run the provided **three independent trading strategies**. All strategies, configurations, and Docker setups are already provided - you just need to install the required software to run them.

---

## 🎯 **What You'll Run**

### **Pre-Built Multi-Strategy Architecture**
- **3 Independent Trading Bots** (FirstStrategy, SecondStrategy, ThirdStrategy) ✅ **Already Created**
- **1 Unified Dashboard** at http://127.0.0.1:8080 ✅ **Already Configured**
- **Separate Docker Containers** for isolation and reliability ✅ **Ready to Deploy**
- **Organized Logging** and database separation ✅ **Already Set Up**
- **Professional-grade Setup** ready for dry-run testing ✅ **Complete**

### **Strategy Overview**
| **Strategy** | **Style** | **Timeframe** | **Risk** | **Expected Activity** |
|-------------|-----------|---------------|----------|---------------------|
| **FirstStrategy** | Conservative RSI + SMA | 5 minutes | 🟢 Low | 1-3 trades/day |
| **SecondStrategy** | EMA + MACD Trend | 15 minutes | 🟡 Medium | 3-6 trades/day |
| **ThirdStrategy** | Bollinger Bands Scalp | 1 minute | 🔴 High | 10-30 trades/day |

---

## 🤔 **Choose Your Setup Method**

### **🐍 Python Environment (Recommended)**
- **Direct control** - Full access to Python environment and dependencies
- **Individual strategy testing** - Run and test one strategy at a time
- **Development-friendly** - Easy debugging and strategy modification
- **Transparent execution** - Direct access to logs and error messages
- **Minimal dependencies** - No containerization overhead

### **🐳 Docker Multi-Strategy (Production-Ready)**
- **Simultaneous execution** - Run all 3 strategies with one command
- **Enterprise-grade isolation** - Separate containers for each strategy
- **Unified monitoring dashboard** - Single interface at one URL
- **Production deployment** - Industry-standard containerization
- **Scalable architecture** - Ready for multi-server deployment

**👉 Choose Python Environment for development/testing, Docker for production deployment.**

---

## 📋 **Prerequisites**

### **For Python Setup:**
- **macOS** (ARM64 or Intel - tested on macOS 15.5)
- **Homebrew** package manager
- **Terminal** access (default Terminal.app or iTerm2)
- **Command line** proficiency

### **For Docker Setup:**
- **macOS** (ARM64 or Intel - tested on macOS 15.5)
- **Docker Desktop** installed and running
- **Terminal** access (default Terminal.app or iTerm2)
- **Docker knowledge** for troubleshooting

### **Hardware Requirements (Both Methods)**
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space
- **Network**: Stable internet connection for market data

---

## 🐍 **Python Environment Setup**

### **Option A: Install Python Environment**

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
# Navigate to your project directory
cd /path/to/your/freqtrade-project

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

# Install TA-Lib Python package
pip install TA-Lib --find-links https://github.com/cgohlke/talib-build/releases/latest --prefer-binary --index-url https://pypi.org/simple/

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

**TA-Lib Compilation Errors:**
```bash
# If TA-Lib fails to install, try:
export TA_LIBRARY_PATH=/opt/homebrew/lib
export TA_INCLUDE_PATH=/opt/homebrew/include
pip install TA-Lib
```

**Corporate Network Issues:**
```bash
# Use direct PyPI if behind corporate firewall
pip install --index-url https://pypi.org/simple/ freqtrade
```

**Virtual Environment Not Working:**
```bash
# Always verify you're in venv
echo $VIRTUAL_ENV
# Should show your venv path

# Reactivate if needed
source .venv/bin/activate
```

### **🎉 Python Environment Ready!**

**Your environment is now set up to run the existing multi-strategy setup!**

**What you can do now:**
- **Run individual strategies** using the provided configs:
  ```bash
  # Run FirstStrategy (Conservative)
  freqtrade trade --config user_data/strategies/FirstStrategy/config_dryrun.json --strategy FirstStrategy
  
  # Run backtests
  freqtrade backtesting --config user_data/strategies/FirstStrategy/config_backtest.json --strategy FirstStrategy
  ```

**Next steps (choose one):**
1. **Deploy Docker multi-strategy** (below) - Run all 3 strategies simultaneously
2. **Execute single strategy with Python** - Use the commands above  
3. **Validate with backtesting** - Read the [Backtesting Guide](BACKTESTING_GUIDE.md) first

---

## ⚡ **Quick Start (15 Minutes)**

### **Option B: Pre-Built Docker Setup (Advanced Users)**

If you have the complete freqtrade-multi-strategy folder:

```bash
# 1. Navigate to your freqtrade directory
cd /path/to/freqtrade-multi-strategy

# 2. Verify all files are present
ls -la docker-compose-multi.yml user_data/

# 3. Start all strategies
docker compose -f docker-compose-multi.yml up -d

# 4. Verify containers are running
docker compose -f docker-compose-multi.yml ps

# 5. Open unified interface
open http://127.0.0.1:8080

# 6. Login with default credentials
# Username: freqtrader
# Password: SuperSecretPassword
```

**Expected Output:**
```
NAME               STATUS              PORTS
freqtrade-first    Up X seconds        127.0.0.1:8080->8080/tcp
freqtrade-second   Up X seconds        127.0.0.1:8081->8081/tcp  
freqtrade-third    Up X seconds        127.0.0.1:8082->8082/tcp
```

**✅ After Python setup, you can run single strategies directly or continue to Docker setup for multi-strategy deployment.**

---

## 🐳 **Docker Multi-Strategy Setup**

### **Option C: Full Docker Setup from Scratch**

**For users who want the complete multi-strategy architecture:**

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

#### **Step 2: Create Project Structure**

```bash
# Create main project directory
mkdir freqtrade-multi-strategy
cd freqtrade-multi-strategy

# Create organized directory structure
mkdir -p user_data/{strategies,logs,backtest_results}
mkdir -p user_data/strategies/{FirstStrategy,SecondStrategy,ThirdStrategy}
mkdir -p user_data/logs/{FirstStrategy,SecondStrategy,ThirdStrategy}
mkdir -p user_data/backtest_results/{FirstStrategy,SecondStrategy,ThirdStrategy}

# Verify structure
tree user_data/ || ls -la user_data/
```

### **Step 3: Create Strategy Files**

**FirstStrategy (Conservative RSI + SMA):**
```bash
cat > user_data/strategies/FirstStrategy/FirstStrategy.py << 'EOF'
from freqtrade.strategy.interface import IStrategy
from pandas import DataFrame
import talib.abstract as ta

class FirstStrategy(IStrategy):
    INTERFACE_VERSION = 3
    
    # Strategy settings
    minimal_roi = {
        "60": 0.01,
        "30": 0.02,
        "0": 0.04
    }
    
    stoploss = -0.10
    timeframe = '5m'
    
    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # RSI
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
        
        # Simple Moving Averages
        dataframe['sma_20'] = ta.SMA(dataframe, timeperiod=20)
        dataframe['sma_50'] = ta.SMA(dataframe, timeperiod=50)
        
        return dataframe
    
    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] < 30) &  # Oversold
                (dataframe['close'] > dataframe['sma_50']) &  # Above long-term trend
                (dataframe['sma_20'] > dataframe['sma_50']) &  # Short-term trend up
                (dataframe['volume'] > 0)
            ),
            'enter_long'] = 1
        
        return dataframe
    
    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] > 70) |  # Overbought
                (dataframe['close'] < dataframe['sma_50'])  # Below trend
            ),
            'exit_long'] = 1
        
        return dataframe
EOF
```

### **Step 4: Create Configuration Files**

**Backtesting Config (StaticPairList):**
```bash
cat > user_data/strategies/FirstStrategy/config_backtest.json << 'EOF'
{
    "trading_mode": "spot",
    "dry_run": true,
    "dry_run_wallet": 1000,
    "stake_currency": "USDT",
    "stake_amount": 50,
    "max_open_trades": 3,
    "timeframe": "5m",
    
    "exchange": {
        "name": "binance",
        "key": "",
        "secret": "",
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT", 
            "ADA/USDT"
        ]
    },
    
    "pairlists": [
        {
            "method": "StaticPairList"
        }
    ],
    
    "entry_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },
    
    "exit_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    }
}
EOF
```

**Live Trading Config (VolumePairList):**
```bash
cat > user_data/strategies/FirstStrategy/config_dryrun.json << 'EOF'
{
    "trading_mode": "spot",
    "dry_run": true,
    "dry_run_wallet": 1000,
    "stake_currency": "USDT",
    "stake_amount": 50,
    "max_open_trades": 3,
    "timeframe": "5m",
    "cancel_open_orders_on_exit": false,
    
    "unfilledtimeout": {
        "entry": 10,
        "exit": 10,
        "exit_timeout_count": 0,
        "unit": "minutes"
    },
    
    "entry_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1,
        "price_last_balance": 0.0,
        "check_depth_of_market": {
            "enabled": false,
            "bids_to_ask_delta": 1
        }
    },
    
    "exit_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },
    
    "exchange": {
        "name": "binance",
        "key": "",
        "secret": "",
        "ccxt_config": {},
        "ccxt_async_config": {},
        "pair_whitelist": [],
        "pair_blacklist": [
            "BNB/.*",
            ".*/BTC",
            ".*/ETH"
        ]
    },
    
    "pairlists": [
        {
            "method": "VolumePairList",
            "number_assets": 10,
            "sort_key": "quoteVolume",
            "min_value": 0,
            "refresh_period": 1800
        },
        {
            "method": "AgeFilter",
            "min_days_listed": 10
        },
        {
            "method": "PrecisionFilter"
        },
        {
            "method": "PriceFilter",
            "low_price_ratio": 0.01
        },
        {
            "method": "SpreadFilter",
            "max_spread_ratio": 0.005
        },
        {
            "method": "RangeStabilityFilter",
            "lookback_days": 10,
            "min_rate_of_change": 0.01,
            "refresh_period": 1440
        }
    ],
    
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": 8080,
        "verbosity": "error",
        "enable_openapi": false,
        "jwt_secret_key": "multi-strategy-secret",
        "CORS_origins": [
            "http://localhost:8080", "http://127.0.0.1:8080",
            "http://localhost:8081", "http://127.0.0.1:8081", 
            "http://localhost:8082", "http://127.0.0.1:8082"
        ],
        "username": "freqtrader",
        "password": "SuperSecretPassword"
    },
    
    "bot_name": "FirstStrategy",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    }
}
EOF
```

### **Step 5: Create Docker Compose Configuration**

```bash
cat > docker-compose-multi.yml << 'EOF'
services:
  # Strategy 1 - FirstStrategy (Conservative RSI + SMA) - MAIN UI
  freqtrade-first:
    image: freqtradeorg/freqtrade:stable
    restart: unless-stopped
    container_name: freqtrade-first
    volumes:
      - "./user_data:/freqtrade/user_data"
    ports:
      - "127.0.0.1:8080:8080"  # Main FreqUI - shows all strategies
    command: >
      trade
      --logfile /freqtrade/user_data/logs/FirstStrategy/freqtrade.log
      --db-url sqlite:////freqtrade/user_data/logs/FirstStrategy/trades.sqlite
      --config /freqtrade/user_data/strategies/FirstStrategy/config_dryrun.json
      --strategy FirstStrategy
      --strategy-path /freqtrade/user_data/strategies/FirstStrategy

  # Strategy 2 - SecondStrategy (EMA + MACD Trend Following)
  freqtrade-second:
    image: freqtradeorg/freqtrade:stable
    restart: unless-stopped
    container_name: freqtrade-second
    volumes:
      - "./user_data:/freqtrade/user_data"
    ports:
      - "127.0.0.1:8081:8081"  # API only - accessed via main UI
    command: >
      trade
      --logfile /freqtrade/user_data/logs/SecondStrategy/freqtrade.log
      --db-url sqlite:////freqtrade/user_data/logs/SecondStrategy/trades.sqlite
      --config /freqtrade/user_data/strategies/SecondStrategy/config_dryrun.json
      --strategy SecondStrategy
      --strategy-path /freqtrade/user_data/strategies/SecondStrategy

  # Strategy 3 - ThirdStrategy (Bollinger Bands Scalping)
  freqtrade-third:
    image: freqtradeorg/freqtrade:stable
    restart: unless-stopped
    container_name: freqtrade-third
    volumes:
      - "./user_data:/freqtrade/user_data"
    ports:
      - "127.0.0.1:8082:8082"  # API only - accessed via main UI
    command: >
      trade
      --logfile /freqtrade/user_data/logs/ThirdStrategy/freqtrade.log
      --db-url sqlite:////freqtrade/user_data/logs/ThirdStrategy/trades.sqlite
      --config /freqtrade/user_data/strategies/ThirdStrategy/config_dryrun.json
      --strategy ThirdStrategy
      --strategy-path /freqtrade/user_data/strategies/ThirdStrategy
EOF
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
# Start all strategies
docker compose -f docker-compose-multi.yml up -d

# Stop all strategies  
docker compose -f docker-compose-multi.yml down

# View logs
docker compose -f docker-compose-multi.yml logs -f

# Restart specific strategy
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