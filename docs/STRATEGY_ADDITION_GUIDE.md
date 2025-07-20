# 🔧 Strategy Addition Guide

## Adding New Strategies to Your Multi-Strategy System

This guide explains how to add a new trading strategy to your existing multi-strategy Freqtrade setup. Follow this structured approach to maintain system organization and ensure proper integration with the unified monitoring interface.

---

## 📋 **Prerequisites**

Before adding a new strategy, ensure you have:
- ✅ A working multi-strategy system (see [Setup Guide](setup-guide.md))
- ✅ Basic understanding of Freqtrade strategy development
- ✅ A strategy file ready for deployment
- ✅ Docker environment properly configured

---

## 🗂️ **Directory Structure Requirements**

### **Critical Directory Organization**

Your new strategy **MUST** follow the established directory structure pattern:

```
user_data/strategies/
├── FirstStrategy/           # Existing strategy
│   ├── FirstStrategy.py
│   ├── config_dryrun.json
│   └── config_backtest.json
├── SecondStrategy/          # Existing strategy
│   ├── SecondStrategy.py
│   ├── config_dryrun.json
│   └── config_backtest.json
├── ThirdStrategy/           # Existing strategy
│   ├── ThirdStrategy.py
│   ├── config_dryrun.json
│   └── config_backtest.json
└── YourNewStrategy/         # Your new strategy
    ├── YourNewStrategy.py
    ├── config_dryrun.json
    └── config_backtest.json
```

### **Required Files for Each Strategy**

Every strategy directory must contain exactly **three files**:

1. **`[StrategyName].py`** - Your trading strategy implementation
2. **`config_dryrun.json`** - Configuration for dry-run trading
3. **`config_backtest.json`** - Configuration for backtesting

⚠️ **Important**: The strategy directory name must match the strategy class name exactly.

---

## 🔧 **Step-by-Step Addition Process**

### **Step 1: Create Strategy Directory**

Create a new directory following the naming convention:
```
user_data/strategies/[YourStrategyName]/
```

**Example**: If your strategy class is called `MomentumStrategy`, create:
```
user_data/strategies/MomentumStrategy/
```

### **Step 2: Add Strategy Files**

Place your three required files in the new directory:

#### **Strategy Implementation File**
- File: `MomentumStrategy.py`
- Contains your trading strategy class
- Must inherit from `IStrategy`

#### **Dry-Run Configuration**
- File: `config_dryrun.json`
- Configuration for live/dry-run trading
- Should use `VolumePairList` for dynamic pair selection
- Reference existing strategy configs for structure

#### **Backtest Configuration**
- File: `config_backtest.json`
- Configuration for historical backtesting
- Should use `StaticPairList` for consistent testing
- Reference existing strategy configs for structure

### **Step 3: Update Docker Compose Configuration**

The docker-compose configuration is **critical** for multi-strategy deployment. You must add a new service for your strategy.

#### **Add New Service to `docker-compose-multi.yml`**

Add a new service block following this pattern:

```yaml
# Strategy N - YourStrategyName (Brief Description)
freqtrade-yourstrategy:
  image: freqtradeorg/freqtrade:stable
  restart: unless-stopped
  container_name: freqtrade-yourstrategy
  volumes:
    - "./user_data:/freqtrade/user_data"
  ports:
    - "127.0.0.1:808X:808X"  # Use next available port
  command: >
    trade
    --logfile /freqtrade/user_data/logs/YourStrategyName/freqtrade.log
    --db-url sqlite:////freqtrade/user_data/logs/YourStrategyName/trades.sqlite
    --config /freqtrade/user_data/strategies/YourStrategyName/config_dryrun.json
    --strategy YourStrategyName
    --strategy-path /freqtrade/user_data/strategies/YourStrategyName
```

#### **Port Assignment Rules**
- **First strategy**: Port 8080 (main UI)
- **Additional strategies**: Ports 8081, 8082, 8083, etc.
- **Your new strategy**: Use the next sequential port number

### **Step 4: Create Log Directory**

Ensure the log directory exists for your strategy:
```
user_data/logs/YourStrategyName/
```

This directory will be automatically created when the container starts, but you can create it manually if needed.

---

## 🧪 **Testing Your New Strategy**

### **Backtesting First**
Before adding to the multi-strategy system, validate your strategy:

1. **Run individual backtest** - Follow [Backtesting Guide](BACKTESTING_GUIDE.md)
2. **Analyze results** - Use [Backtest Analysis Guide](BACKTEST_ANALYSIS.md)
3. **Optimize parameters** - Ensure strategy performs as expected

### **Dry-Run Integration**
After backtesting validation:

1. **Deploy with docker-compose** - Follow [Unified UI Guide](UNIFIED_UI_GUIDE.md)
2. **Start dry-run trading** - Use [Dry Run Operations Guide](DRY_RUN_GUIDE.md)
3. **Monitor performance** - Apply [Monitoring Guide](MONITORING_GUIDE.md)

---

## ⚙️ **Configuration Considerations**

### **Database Isolation**
Each strategy gets its own SQLite database:
- **Location**: `/freqtrade/user_data/logs/[StrategyName]/trades.sqlite`
- **Purpose**: Isolated trade history and state management
- **Benefit**: Independent operation and easier debugging

### **Log File Separation**
Each strategy maintains separate logs:
- **Location**: `/freqtrade/user_data/logs/[StrategyName]/freqtrade.log`
- **Purpose**: Strategy-specific debugging and monitoring
- **Benefit**: Clear separation of strategy events

### **API Port Isolation**
Each strategy runs on its own port:
- **Purpose**: Independent API access for monitoring
- **Integration**: Unified UI aggregates all strategy APIs
- **Security**: CORS configuration allows cross-strategy access

---

## 🔍 **Unified Interface Integration**

### **Automatic Detection**
Your new strategy will be automatically available in the unified interface when:
- ✅ Docker container is running successfully
- ✅ API is responding on assigned port
- ✅ CORS is properly configured
- ✅ Strategy is listed in FreqUI dropdown

### **Strategy Switching**
Access your new strategy through:
1. **Main UI**: http://127.0.0.1:8080
2. **Strategy dropdown** in the FreqUI interface
3. **Direct API access**: http://127.0.0.1:808X (your assigned port)

---

## 🚨 **Common Pitfalls to Avoid**

### **Directory Structure Issues**
- ❌ Mismatched directory and strategy class names
- ❌ Missing required configuration files
- ❌ Incorrect file naming conventions

### **Docker Configuration Issues**
- ❌ Port conflicts (using already assigned ports)
- ❌ Incorrect volume mappings
- ❌ Wrong strategy-path configuration

### **Configuration Issues**
- ❌ Using VolumePairList in backtest config
- ❌ Using StaticPairList in dry-run config
- ❌ Mismatched strategy names in config files

---

## 📚 **Reference Documentation**

For detailed implementation instructions, refer to these guides:

- **[Setup Guide](setup-guide.md)** - Initial system configuration
- **[Backtesting Guide](BACKTESTING_GUIDE.md)** - Strategy validation process
- **[Backtest Analysis](BACKTEST_ANALYSIS.md)** - Performance evaluation
- **[Unified UI Guide](UNIFIED_UI_GUIDE.md)** - Multi-strategy deployment
- **[Dry Run Operations Guide](DRY_RUN_GUIDE.md)** - Safe strategy testing
- **[Monitoring Guide](MONITORING_GUIDE.md)** - Strategy performance tracking

---

## ✅ **Verification Checklist**

Before considering your strategy addition complete:

- [ ] ✅ Strategy directory created with correct naming
- [ ] ✅ All three required files present (*.py, config_dryrun.json, config_backtest.json)
- [ ] ✅ Docker service added to docker-compose-multi.yml
- [ ] ✅ Unique port assigned (not conflicting with existing strategies)
- [ ] ✅ Strategy successfully backtested
- [ ] ✅ Container starts without errors
- [ ] ✅ Strategy appears in FreqUI dropdown
- [ ] ✅ API responds on assigned port
- [ ] ✅ Logs are being written to correct directory
- [ ] ✅ Database file created successfully

---

## 🎯 **Next Steps**

After successfully adding your strategy:

1. **Validate Performance** - Run extended dry-run testing
2. **Monitor Behavior** - Use monitoring tools to track strategy performance
3. **Optimize Parameters** - Fine-tune based on real market behavior
4. **Document Strategy** - Keep notes on strategy logic and performance
5. **Consider Live Trading** - Only after thorough validation and testing

---

**Need help with any of these steps? Refer to the specific operational guides linked throughout this document!** 🚀 