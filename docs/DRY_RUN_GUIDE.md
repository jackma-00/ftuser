# 🎯 Dry Run Operations Guide

## Complete Guide to Starting and Stopping Freqtrade Dry Run Mode

This guide covers how to operate the **three example strategies provided in dry run mode** - risk-free simulation trading that lets you test strategies with virtual money before going live.

---

## ⚡ **Quick Commands Reference**

### **Most Common Operations**
```bash
# Start all containers
docker compose -f docker-compose-multi.yml up -d

# Stop strategy gracefully (recommended) - keeps container running
curl -X POST http://127.0.0.1:8080/api/v1/stop -H "Content-Type: application/json" -u freqtrader:SuperSecretPassword

# Start stopped strategy
curl -X POST http://127.0.0.1:8080/api/v1/start -H "Content-Type: application/json" -u freqtrader:SuperSecretPassword

# Stop containers (when needed)
docker compose -f docker-compose-multi.yml stop

# Check status
docker compose -f docker-compose-multi.yml ps
curl -s http://127.0.0.1:8080/api/v1/count -u freqtrader:SuperSecretPassword
```

**💡 Tip**: Use FreqUI at http://127.0.0.1:8080 for easier point-and-click control!

---

## 🔍 **What is Dry Run Mode?**

**Dry Run** is Freqtrade's simulation mode that:
- ✅ **Executes all trading logic** without real money
- ✅ **Uses real market data** for accurate simulation
- ✅ **Tracks virtual profits/losses** with a virtual wallet
- ✅ **Tests strategies safely** before live trading
- ✅ **Provides full monitoring** through FreqUI dashboard

### **Dry Run vs Live Trading**
| Feature | Dry Run | Live Trading |
|---------|---------|-------------|
| **Real Money** | ❌ Virtual | ✅ Real |
| **Market Data** | ✅ Real-time | ✅ Real-time |
| **Strategy Logic** | ✅ Full execution | ✅ Full execution |
| **Risk** | 🟢 Zero | 🔴 Financial |
| **Testing** | ✅ Perfect for testing | ❌ Risk involved |

---

## 🏗️ **Current Dry Run Setup Overview**

Your system is configured to run **three independent strategies** in dry run mode:

### **Strategy Configuration**
| Strategy | Container | Virtual Wallet | Max Trades | Timeframe | Risk Profile |
|----------|-----------|----------------|------------|-----------|--------------|
| **FirstStrategy** | freqtrade-first | $1,000 USDT | 3 trades | 5 minutes | 🟢 Conservative |
| **SecondStrategy** | freqtrade-second | $1,000 USDT | 5 trades | 15 minutes | 🟡 Moderate |
| **ThirdStrategy** | freqtrade-third | $1,000 USDT | 10 trades | 1 minute | 🔴 Aggressive |

### **Access Points**
- **Main Dashboard**: http://127.0.0.1:8080 (FirstStrategy + controls for all)
- **SecondStrategy API**: http://127.0.0.1:8081 (accessed via main dashboard)
- **ThirdStrategy API**: http://127.0.0.1:8082 (accessed via main dashboard)

---

## 🚀 **Starting Dry Run Operations**

### **Start All Strategies (Recommended)**
```bash
# Navigate to your project directory
cd /path/to/your/freqtrade-project

# Start all three containers with respective strategies in dry run mode
docker compose -f docker-compose-multi.yml up -d

# Verify all containers are running
docker compose -f docker-compose-multi.yml ps

# Expected output:
# freqtrade-first    Up X seconds   127.0.0.1:8080->8080/tcp
# freqtrade-second   Up X seconds   127.0.0.1:8081->8081/tcp  
# freqtrade-third    Up X seconds   127.0.0.1:8082->8082/tcp
```

### **Start Individual Strategies**
```bash
# Start only the FirstStrategy container (Conservative)
docker compose -f docker-compose-multi.yml up -d freqtrade-first

# Start only the SecondStrategy container (Trend Following)
docker compose -f docker-compose-multi.yml up -d freqtrade-second

# Start only the ThirdStrategy container (Scalping)
docker compose -f docker-compose-multi.yml up -d freqtrade-third

# Start specific combination (e.g., only conservative strategies)
docker compose -f docker-compose-multi.yml up -d freqtrade-first freqtrade-second
```

### **Verify Successful Startup**
```bash
# Check container health
docker compose -f docker-compose-multi.yml ps

# Test API endpoints
curl -s http://127.0.0.1:8080/api/v1/ping && echo "✅ FirstStrategy API OK"
curl -s http://127.0.0.1:8081/api/v1/ping && echo "✅ SecondStrategy API OK"
curl -s http://127.0.0.1:8082/api/v1/ping && echo "✅ ThirdStrategy API OK"

# Quick health check for all
for port in 8080 8081 8082; do 
  curl -s http://127.0.0.1:$port/api/v1/ping >/dev/null && echo "Port $port: ✅" || echo "Port $port: ❌"
done
```

### **Access FreqUI Dashboard**
1. **Open your browser** and navigate to: http://127.0.0.1:8080
2. **Login credentials**:
   - Username: `freqtrader`
   - Password: `SuperSecretPassword`
3. **Add other strategies** (if not already configured):
   - Click "Add new bot" in settings
   - SecondStrategy: `http://127.0.0.1:8081`
   - ThirdStrategy: `http://127.0.0.1:8082`

---

## ⏸️ **Stopping/Pausing Strategies (Graceful - Recommended)**

You can stop or pause individual strategies **without killing containers** using either the FreqUI interface or REST API commands. This is the **recommended approach** for temporary stops.

### **Using FreqUI Interface (Easiest)**
1. **Open FreqUI Dashboard**: http://127.0.0.1:8080
2. **Navigate to Trade View** (main dashboard)
3. **Use Bot Controls**:
   - **Stop Button**: Gracefully stops the strategy while keeping container running
   - **Start Button**: Restarts a stopped strategy
   - **Force entries/exits**: Available if needed

### **Using REST API Commands**
```bash
# Stop specific strategy gracefully (recommended for temporary stops)
curl -X POST http://127.0.0.1:8080/api/v1/stop \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword

# Stop SecondStrategy
curl -X POST http://127.0.0.1:8081/api/v1/stop \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword

# Stop ThirdStrategy  
curl -X POST http://127.0.0.1:8082/api/v1/stop \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword

# Pause strategy (handles open positions gracefully)
curl -X POST http://127.0.0.1:8080/api/v1/pause \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword

# Stop buying only (but handle existing sells gracefully)
curl -X POST http://127.0.0.1:8080/api/v1/stopbuy \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword
```

### **Using freqtrade-client (Alternative)**
```bash
# Install freqtrade-client if not already available
pip install freqtrade-client

# Stop FirstStrategy
freqtrade-client --config user_data/strategies/FirstStrategy/config_dryrun.json stop

# Stop SecondStrategy  
freqtrade-client --config user_data/strategies/SecondStrategy/config_dryrun.json stop

# Stop ThirdStrategy
freqtrade-client --config user_data/strategies/ThirdStrategy/config_dryrun.json stop
```

### **Verify Strategy Stopped**
```bash
# Check status via API
curl -s http://127.0.0.1:8080/api/v1/count -u freqtrader:SuperSecretPassword
curl -s http://127.0.0.1:8081/api/v1/count -u freqtrader:SuperSecretPassword  
curl -s http://127.0.0.1:8082/api/v1/count -u freqtrader:SuperSecretPassword

# Expected response: {"error":"Error querying /api/v1/count: trader is not running"} when stopped

# Check container is still running
docker compose -f docker-compose-multi.yml ps

# Should show containers as "Up" even though strategies are stopped
```

---

## ▶️ **Starting Stopped Strategies**

### **Using FreqUI Interface**
1. **Open FreqUI Dashboard**: http://127.0.0.1:8080
2. **Click "Start" button** in the Trade View

### **Using REST API Commands**
```bash
# Start stopped strategies
curl -X POST http://127.0.0.1:8080/api/v1/start \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword

curl -X POST http://127.0.0.1:8081/api/v1/start \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword

curl -X POST http://127.0.0.1:8082/api/v1/start \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword

# Reload configuration (if you've made changes)
curl -X POST http://127.0.0.1:8080/api/v1/reload_config \
  -H "Content-Type: application/json" \
  -u freqtrader:SuperSecretPassword
```

### **Using freqtrade-client**
```bash
# Start specific strategy
freqtrade-client --config user_data/strategies/FirstStrategy/config_dryrun.json start
freqtrade-client --config user_data/strategies/SecondStrategy/config_dryrun.json start
freqtrade-client --config user_data/strategies/ThirdStrategy/config_dryrun.json start

# Reload config after changes
freqtrade-client --config user_data/strategies/FirstStrategy/config_dryrun.json reload_config
freqtrade-client --config user_data/strategies/SecondStrategy/config_dryrun.json reload_config
freqtrade-client --config user_data/strategies/ThirdStrategy/config_dryrun.json reload_config
```

---

## 🛑 **Stopping Containers (When Needed)**

**⚠️ Use container stopping only when necessary** (system maintenance, configuration changes requiring restart, etc.)

> **📝 Important:** `docker compose down` completely **removes** containers (not just stops them). All runtime state is lost, but your configuration files and data in `user_data/` volumes are preserved. Use `docker compose up -d` to recreate and start fresh containers.

### **Graceful Container Stop (Recommended)**
```bash
# Stop all strategies gracefully first, then containers
for port in 8080 8081 8082; do
  curl -X POST http://127.0.0.1:$port/api/v1/stop \
    -H "Content-Type: application/json" \
    -u freqtrader:SuperSecretPassword
done

# Wait for strategies to close positions (30 seconds)
sleep 30

# Then stop containers
docker compose -f docker-compose-multi.yml stop

# Verify all containers are stopped
docker compose -f docker-compose-multi.yml ps
```

### **Stop All Containers**
```bash
# Immediate container shutdown (strategies stop automatically)
docker compose -f docker-compose-multi.yml stop

# Verify all containers are stopped
docker compose -f docker-compose-multi.yml ps

# Force stop if needed (not recommended, may lose data)
docker compose -f docker-compose-multi.yml down --remove-orphans
```

### **Stop Individual Containers**
```bash
# Stop specific strategy container
docker compose -f docker-compose-multi.yml stop freqtrade-first
docker compose -f docker-compose-multi.yml stop freqtrade-second
docker compose -f docker-compose-multi.yml stop freqtrade-third

# Stop multiple specific strategies
docker compose -f docker-compose-multi.yml stop freqtrade-first freqtrade-second

# Remove specific containers (will restart on next 'up' command)
docker compose -f docker-compose-multi.yml rm -f freqtrade-first
```

### **Emergency Stop**
```bash
# Immediate stop all containers (if unresponsive)
docker stop freqtrade-first freqtrade-second freqtrade-third

# Force kill containers (last resort)
docker kill freqtrade-first freqtrade-second freqtrade-third

# Clean up if needed
docker container prune -f
```

---

## 🔄 **Restart Operations**

### **Restart All Containers**
```bash
# Restart all with configuration reload
docker compose -f docker-compose-multi.yml restart

# Or remove and start fresh
docker compose -f docker-compose-multi.yml down
docker compose -f docker-compose-multi.yml up -d
```

### **Restart Individual Strategies**
```bash
# Restart specific strategy (reload config)
docker compose -f docker-compose-multi.yml restart freqtrade-first
docker compose -f docker-compose-multi.yml restart freqtrade-second
docker compose -f docker-compose-multi.yml restart freqtrade-third

# Restart with fresh container
docker compose -f docker-compose-multi.yml stop freqtrade-first
docker compose -f docker-compose-multi.yml up -d freqtrade-first
```

---

## 📊 **Monitoring Dry Run Operations**

### **Real-time Status Check**
```bash
# Quick status overview
docker compose -f docker-compose-multi.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Container resource usage
docker stats freqtrade-first freqtrade-second freqtrade-third --no-stream

# Recent activity summary
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  echo "=== $strategy Recent Activity ==="
  tail -5 user_data/logs/$strategy/freqtrade.log | grep -E "(heartbeat|entry|exit|profit)"
done
```

### **View Live Logs**
```bash
# Monitor all strategies simultaneously
docker compose -f docker-compose-multi.yml logs -f

# Monitor individual strategy logs
docker logs -f freqtrade-first    # FirstStrategy
docker logs -f freqtrade-second   # SecondStrategy  
docker logs -f freqtrade-third    # ThirdStrategy

# File-based log monitoring with strategy labels
tail -f user_data/logs/FirstStrategy/freqtrade.log | sed 's/^/[FirstStrategy] /' &
tail -f user_data/logs/SecondStrategy/freqtrade.log | sed 's/^/[SecondStrategy] /' &
tail -f user_data/logs/ThirdStrategy/freqtrade.log | sed 's/^/[ThirdStrategy] /' &
```

### **🎛️ Strategy Control Options**
You have **multiple ways** to control your strategies:

| Method | Use Case | Impact | Restart Time |
|--------|----------|--------|--------------|
| **API/UI Stop** | 🟢 Temporary pause, testing | Strategy stops, container running | Instant |
| **API/UI Pause** | 🟡 Pause with position handling | Graceful position closure | Instant |
| **Stopbuy** | 🟡 Stop new trades only | No new entries, handles exits | Instant |
| **Container Stop** | 🔴 Maintenance, config changes | Full container shutdown | 30-60 seconds |

### **📈 For Comprehensive Monitoring**
**Continue to the [Multi-Strategy Monitoring Guide](MONITORING_GUIDE.md)** for:
- ✅ **Detailed performance tracking**
- ✅ **Strategy-specific monitoring**
- ✅ **Error detection and alerts**
- ✅ **FreqUI dashboard usage**
- ✅ **Automated health checks**

---

## ⚙️ **Configuration Management**

### **Dry Run Configuration Files**
Each strategy has its own dry run configuration:
```
user_data/strategies/
├── FirstStrategy/
│   ├── config_dryrun.json     ← Dry run settings
│   └── config_backtest.json   ← Backtest settings
├── SecondStrategy/
│   ├── config_dryrun.json
│   └── config_backtest.json
└── ThirdStrategy/
    ├── config_dryrun.json
    └── config_backtest.json
```

### **Key Dry Run Settings**
Each `config_dryrun.json` contains:
```json
{
    "dry_run": true,                 // Enables simulation mode
    "dry_run_wallet": 1000,          // Virtual USDT wallet
    "stake_amount": 50,              // Amount per trade
    "max_open_trades": 3,            // Max concurrent trades
    "tradable_balance_ratio": 0.3    // Use 30% of wallet
}
```

### **Modify Dry Run Settings**
```bash
# Edit FirstStrategy dry run config
nano user_data/strategies/FirstStrategy/config_dryrun.json

# After editing, restart the specific strategy
docker compose -f docker-compose-multi.yml restart freqtrade-first

# Verify configuration loaded correctly
docker logs freqtrade-first | grep -i "dry.*run\|wallet" | tail -5
```

---

## 🔍 **Dry Run Validation & Testing**

### **Verify Dry Run Mode is Active**
```bash
# Check each strategy is running in dry run mode
for port in 8080 8081 8082; do
  echo "Port $port status:"
  curl -s http://127.0.0.1:$port/api/v1/balance -u freqtrader:SuperSecretPassword | jq '.note'
done

# Expected response: "Simulated balances" for dry run mode

# Check log files for dry run confirmation
grep -i "dry.*run" user_data/logs/*/freqtrade.log | head -3
```

### **Test Virtual Trading**
```bash
# Monitor for simulated trades
grep -i "dry.*run.*buy\|dry.*run.*sell" user_data/logs/*/freqtrade.log | tail -10

# Check virtual wallet balances via API
curl -s http://127.0.0.1:8080/api/v1/balance -u freqtrader:SuperSecretPassword | jq '.'

# Monitor trade simulation activity
watch -n 10 'grep -c "$(date +%Y-%m-%d)" user_data/logs/*/freqtrade.log'
```

---

## 🚨 **Troubleshooting Dry Run Issues**

### **Container Won't Start**
```bash
# Check for port conflicts (macOS)
lsof -i :8080 -i :8081 -i :8082

# For Linux systems use:
# netstat -tuln | grep -E "8080|8081|8082"

# View container startup errors
docker compose -f docker-compose-multi.yml logs freqtrade-first

# Check configuration syntax
python -m json.tool user_data/strategies/FirstStrategy/config_dryrun.json

# Restart with fresh container
docker compose -f docker-compose-multi.yml down
docker compose -f docker-compose-multi.yml up -d
```

### **No Trading Activity**
```bash
# Check if strategy is receiving market data
docker logs freqtrade-first | grep -i "pairs\|market\|refresh" | tail -5

# Verify exchange connection
docker logs freqtrade-first | grep -i "exchange\|connect" | tail -3

# Check strategy entry conditions
docker logs freqtrade-first | grep -i "signal\|entry.*condition" | tail -5
```

### **FreqUI Not Accessible**
```bash
# Verify container is running and port is exposed
docker compose -f docker-compose-multi.yml ps

# Check if port 8080 is available
curl -v http://127.0.0.1:8080/api/v1/ping

# Restart FreqUI service
docker compose -f docker-compose-multi.yml restart freqtrade-first
```

---

## 📋 **Dry Run Operations Checklist**

### **Before Starting Dry Run**
- [ ] ✅ Docker is running
- [ ] ✅ No port conflicts (8080, 8081, 8082)
- [ ] ✅ Configuration files are valid JSON
- [ ] ✅ `dry_run: true` in all config files
- [ ] ✅ Virtual wallet amounts are set

### **After Starting Dry Run**
- [ ] ✅ All containers are running
- [ ] ✅ APIs respond to ping
- [ ] ✅ FreqUI dashboard accessible
- [ ] ✅ Strategies show "dry run" status
- [ ] ✅ Log files are being created

### **During Operation**
- [ ] ✅ Monitor using [Monitoring Guide](MONITORING_GUIDE.md)
- [ ] ✅ Check for trading activity
- [ ] ✅ Verify virtual wallet balances
- [ ] ✅ Review strategy performance

### **Before Stopping**
- [ ] ✅ Review session performance
- [ ] ✅ Save important log data if needed
- [ ] ✅ Note any configuration changes
- [ ] ✅ Use graceful stop (API/UI) instead of killing containers when possible

---

## 🎯 **Next Steps**

1. **Start your dry run operations** using the commands above
2. **Monitor performance** with the [Monitoring Guide](MONITORING_GUIDE.md)
3. **Analyze results** using the [Backtest Analysis Guide](BACKTEST_ANALYSIS.md)
4. **Optimize strategies** based on dry run performance
5. **Consider live trading** only after successful dry run validation

---

## 🔗 **Related Guides**

- 📊 **[Multi-Strategy Monitoring Guide](MONITORING_GUIDE.md)** - Comprehensive monitoring for all strategies
- 📈 **[Backtest Analysis Guide](BACKTEST_ANALYSIS.md)** - Analyze strategy performance
- 🎛️ **[Unified UI Guide](UNIFIED_UI_GUIDE.md)** - FreqUI dashboard usage
- 📚 **[Backtesting Guide](BACKTESTING_GUIDE.md)** - Historical strategy testing

---

**Your dry run operations are now ready for safe, risk-free strategy testing! 🎯** 