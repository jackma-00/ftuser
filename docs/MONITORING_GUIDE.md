# 📊 Multi-Strategy Monitoring Guide

## Comprehensive Monitoring for Independent Trading Strategies

This guide covers monitoring the **three example strategies provided** running in separate Docker containers. Each strategy operates autonomously while providing centralized monitoring through a unified interface.

---

## 🎯 **Multi-Container Monitoring Overview**

### **Current Architecture Status**

| Strategy | Container | Status | UI Access | Log Location | Database |
|----------|-----------|--------|-----------|--------------|----------|
| **FirstStrategy** | freqtrade-first | ✅ Running | [Port 8080](http://127.0.0.1:8080) | `logs/FirstStrategy/` | `logs/FirstStrategy/trades.sqlite` |
| **SecondStrategy** | freqtrade-second | ✅ Running | Via Main UI | `logs/SecondStrategy/` | `logs/SecondStrategy/trades.sqlite` |
| **ThirdStrategy** | freqtrade-third | ✅ Running | Via Main UI | `logs/ThirdStrategy/` | `logs/ThirdStrategy/trades.sqlite` |

### **🔗 Unified Access Point**
**Main Interface**: http://127.0.0.1:8080 - Monitor all strategies from one dashboard

---

## 📁 **Organized Monitoring Structure**

```
user_data/
├── logs/                        # Separated by strategy
│   ├── FirstStrategy/
│   │   ├── freqtrade.log        # Strategy-specific logs
│   │   ├── trades.sqlite        # Independent trade database
│   │   ├── trades.sqlite-shm    # Database shared memory
│   │   └── trades.sqlite-wal    # Database write-ahead log
│   ├── SecondStrategy/
│   │   └── [same structure]
│   └── ThirdStrategy/
│       └── [same structure]
├── backtest_results/            # Historical analysis
│   ├── FirstStrategy/
│   ├── SecondStrategy/
│   └── ThirdStrategy/
└── strategies/                  # Strategy configurations
    ├── FirstStrategy/
    │   ├── FirstStrategy.py
    │   ├── config_backtest.json     # StaticPairList for testing
    │   └── config_dryrun.json       # VolumePairList for live trading
    ├── SecondStrategy/
    └── ThirdStrategy/
```

---

## 🔍 **Real-Time Monitoring Commands**

### **Container Health Check**
```bash
# View all strategy containers with status
docker compose -f docker-compose-multi.yml ps

# Expected output:
# freqtrade-first    Up X minutes   127.0.0.1:8080->8080/tcp
# freqtrade-second   Up X minutes   127.0.0.1:8081->8081/tcp
# freqtrade-third    Up X minutes   127.0.0.1:8082->8082/tcp
```

### **API Health Verification**
```bash
# Test all strategy APIs simultaneously
curl -s http://127.0.0.1:8080/api/v1/ping && echo " - FirstStrategy OK"
curl -s http://127.0.0.1:8081/api/v1/ping && echo " - SecondStrategy OK"  
curl -s http://127.0.0.1:8082/api/v1/ping && echo " - ThirdStrategy OK"

# One-liner health check
for port in 8080 8081 8082; do curl -s http://127.0.0.1:$port/api/v1/ping >/dev/null && echo "Port $port: ✅" || echo "Port $port: ❌"; done
```

### **Live Log Monitoring**
```bash
# Monitor all strategies simultaneously (combined output)
docker compose -f docker-compose-multi.yml logs -f

# Monitor individual strategies
docker logs -f freqtrade-first    # FirstStrategy (Conservative)
docker logs -f freqtrade-second   # SecondStrategy (Trend Following)
docker logs -f freqtrade-third    # ThirdStrategy (Scalping)

# File-based log monitoring with strategy names
tail -f user_data/logs/FirstStrategy/freqtrade.log | sed 's/^/[FirstStrategy] /' &
tail -f user_data/logs/SecondStrategy/freqtrade.log | sed 's/^/[SecondStrategy] /' &
tail -f user_data/logs/ThirdStrategy/freqtrade.log | sed 's/^/[ThirdStrategy] /' &
```

---

## 📈 **Strategy Performance Monitoring**

### **Real-Time Trading Activity**
```bash
# Check for active trading across all strategies
grep -i "buy\|sell\|entry\|exit" user_data/logs/*/freqtrade.log | tail -20

# Strategy-specific trading activity
grep -i "buy\|sell" user_data/logs/FirstStrategy/freqtrade.log | tail -10
grep -i "buy\|sell" user_data/logs/SecondStrategy/freqtrade.log | tail -10
grep -i "buy\|sell" user_data/logs/ThirdStrategy/freqtrade.log | tail -10

# Count trades per strategy today
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  count=$(grep -c "$(date +%Y-%m-%d)" user_data/logs/$strategy/freqtrade.log)
  echo "$strategy: $count log entries today"
done
```

### **Log File Growth Monitoring**
```bash
# Monitor log file sizes (growing = active)
ls -lh user_data/logs/*/freqtrade.log

# Watch log growth in real-time
watch -n 5 'ls -lh user_data/logs/*/freqtrade.log'

# Find most active strategy by log size
du -sh user_data/logs/*/freqtrade.log | sort -rh
```

### **Error and Warning Detection**
```bash
# Check for errors across all strategies
grep -i error user_data/logs/*/freqtrade.log | tail -10

# Check for warnings
grep -i warning user_data/logs/*/freqtrade.log | tail -10

# Strategy-specific error monitoring
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  echo "=== $strategy Errors ==="
  grep -i error user_data/logs/$strategy/freqtrade.log | tail -3
done
```

---

## 🌐 **FreqUI Dashboard Monitoring**

### **Multi-Strategy Dashboard Access**
- **Primary Interface**: [FirstStrategy Dashboard](http://127.0.0.1:8080)
- **Strategy Switching**: Use dropdown in top-left to switch between strategies
- **Bot Management**: Add secondary strategies (ports 8081, 8082) in settings

### **Dashboard Features by Strategy**

| **Feature** | **FirstStrategy** | **SecondStrategy** | **ThirdStrategy** |
|-------------|-------------------|-------------------|-------------------|
| **Dashboard Access** | ✅ Direct (8080) | ✅ Via Dropdown | ✅ Via Dropdown |
| **Real-time Charts** | ✅ Full | ✅ Full | ✅ Full |
| **Trade History** | ✅ Independent | ✅ Independent | ✅ Independent |
| **Profit/Loss** | ✅ Live Updates | ✅ Live Updates | ✅ Live Updates |
| **Strategy Control** | ✅ Start/Stop | ✅ Start/Stop | ✅ Start/Stop |

### **FreqUI Monitoring Workflow**
1. **Open Main Dashboard**: http://127.0.0.1:8080
2. **Login**: freqtrader / SuperSecretPassword
3. **Add Other Bots** (if not already configured):
   - SecondStrategy: http://127.0.0.1:8081
   - ThirdStrategy: http://127.0.0.1:8082
4. **Switch Between Strategies**: Use bot dropdown menu
5. **Monitor Performance**: Compare profits, trades, and activity

---

## 📊 **Strategy-Specific Monitoring**

### **FirstStrategy (Conservative RSI + SMA)**
**Expected Behavior:**
- **Timeframe**: 5 minutes
- **Activity Level**: 1-3 trades per day
- **Pairs**: Dynamically selected by VolumePairList (typically BTC/USDT, ETH/USDT)
- **Risk Profile**: 🟢 Low risk, higher accuracy

**Monitoring Commands:**
```bash
# Check recent FirstStrategy activity
tail -50 user_data/logs/FirstStrategy/freqtrade.log | grep -E "(heartbeat|entry|exit)"

# Monitor specific indicators
grep -i "rsi\|sma" user_data/logs/FirstStrategy/freqtrade.log | tail -5

# Check current pairs being traded
docker logs freqtrade-first | grep -i "whitelist" | tail -1
```

### **SecondStrategy (EMA + MACD Trend Following)**
**Expected Behavior:**
- **Timeframe**: 15 minutes
- **Activity Level**: 3-6 trades per day
- **Pairs**: Focus on trending pairs (SOL, DOT, LINK type assets)
- **Risk Profile**: 🟡 Medium risk, trend-following

**Monitoring Commands:**
```bash
# Check SecondStrategy trend signals
tail -50 user_data/logs/SecondStrategy/freqtrade.log | grep -E "(MACD|EMA|trend)"

# Monitor for entry conditions
docker logs freqtrade-second | grep -i "signal\|entry" | tail -10

# Check API status
curl -s http://127.0.0.1:8081/api/v1/count -u freqtrader:SuperSecretPassword | jq '.'
```

### **ThirdStrategy (Bollinger Bands Scalping)**
**Expected Behavior:**
- **Timeframe**: 1 minute
- **Activity Level**: 20-50 trades per day (high frequency)
- **Pairs**: Volatile pairs (DOGE, SHIB, XRP type assets)
- **Risk Profile**: 🔴 High risk, quick scalping

**Monitoring Commands:**
```bash
# Monitor high-frequency scalping activity
tail -100 user_data/logs/ThirdStrategy/freqtrade.log | grep -E "(entry|exit)" | wc -l

# Check Bollinger Band signals
grep -i "bollinger\|bb_" user_data/logs/ThirdStrategy/freqtrade.log | tail -5

# Monitor rapid trading frequency
watch -n 30 'docker logs freqtrade-third | grep -c "$(date +%Y-%m-%d)"'
```

---

## 🚨 **Alert & Notification Monitoring**

### **Automated Health Checks**
```bash
# Create a monitoring script
cat > monitor_all_strategies.sh << 'EOF'
#!/bin/bash
echo "=== Multi-Strategy Health Check $(date) ==="

# Container status
echo "Container Status:"
docker compose -f docker-compose-multi.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# API Health
echo -e "\nAPI Health:"
for port in 8080 8081 8082; do
  if curl -s http://127.0.0.1:$port/api/v1/ping >/dev/null; then
    echo "Port $port: ✅ Healthy"
  else
    echo "Port $port: ❌ Unhealthy"
  fi
done

# Recent errors
echo -e "\nRecent Errors:"
grep -i error user_data/logs/*/freqtrade.log | tail -5 || echo "No recent errors"

# Trading activity (last hour)
echo -e "\nTrading Activity (last 1 hour):"
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  # macOS compatible date command (1 hour ago)
  hour_ago=$(date -v-1H '+%Y-%m-%d %H' 2>/dev/null || date -d '1 hour ago' '+%Y-%m-%d %H' 2>/dev/null || echo "$(date '+%Y-%m-%d %H')")
  count=$(grep "$hour_ago" user_data/logs/$strategy/freqtrade.log 2>/dev/null | wc -l)
  echo "$strategy: $count log entries in last hour"
done

echo "=== End Health Check ==="
EOF

chmod +x monitor_all_strategies.sh
```

### **Performance Alerts**
```bash
# Check for unusual activity patterns
cat > check_strategy_alerts.sh << 'EOF'
#!/bin/bash

# Check if any strategy is inactive (no heartbeat in 10 minutes)
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  last_heartbeat=$(grep "heartbeat" user_data/logs/$strategy/freqtrade.log | tail -1 | cut -d' ' -f1-2)
  if [ -n "$last_heartbeat" ]; then
    # Cross-platform date parsing (macOS and Linux compatible)
    if [[ "$OSTYPE" == "darwin"* ]]; then
      last_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "$last_heartbeat" +%s 2>/dev/null || echo "0")
    else
      last_time=$(date -d "$last_heartbeat" +%s 2>/dev/null || echo "0")
    fi
    current_time=$(date +%s)
    diff=$((current_time - last_time))
    if [ $diff -gt 600 ]; then  # 10 minutes
      echo "⚠️  $strategy: No heartbeat for $((diff/60)) minutes"
    fi
  fi
done

# Check for error spikes
error_count=$(grep -c "$(date '+%Y-%m-%d %H')" user_data/logs/*/freqtrade.log | grep error | wc -l)
if [ $error_count -gt 10 ]; then
  echo "🚨 High error count this hour: $error_count"
fi
EOF

chmod +x check_strategy_alerts.sh
```

---

## 🔄 **Container Management & Control**

### **Individual Strategy Control**
```bash
# Start specific strategy
docker compose -f docker-compose-multi.yml start freqtrade-first
docker compose -f docker-compose-multi.yml start freqtrade-second
docker compose -f docker-compose-multi.yml start freqtrade-third

# Stop specific strategy
docker compose -f docker-compose-multi.yml stop freqtrade-first
docker compose -f docker-compose-multi.yml stop freqtrade-second
docker compose -f docker-compose-multi.yml stop freqtrade-third

# Restart specific strategy
docker compose -f docker-compose-multi.yml restart freqtrade-first
docker compose -f docker-compose-multi.yml restart freqtrade-second
docker compose -f docker-compose-multi.yml restart freqtrade-third

# View container resource usage
docker stats freqtrade-first freqtrade-second freqtrade-third
```

### **Bulk Operations**
```bash
# Start all strategies
docker compose -f docker-compose-multi.yml up -d

# Stop all strategies
docker compose -f docker-compose-multi.yml down

# Restart all strategies
docker compose -f docker-compose-multi.yml restart

# View all logs simultaneously
docker compose -f docker-compose-multi.yml logs -f --tail=50
```

---

## 📊 **Performance Tracking & Analysis**

### **Daily Performance Summary**
```bash
# Generate daily report
cat > daily_report.sh << 'EOF'
#!/bin/bash
echo "=== Daily Multi-Strategy Report $(date +%Y-%m-%d) ==="

for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  echo -e "\n--- $strategy ---"
  
  # Log entries today
  today_logs=$(grep -c "$(date +%Y-%m-%d)" user_data/logs/$strategy/freqtrade.log 2>/dev/null || echo "0")
  echo "Log entries today: $today_logs"
  
  # Trading activity
  trades_today=$(grep "$(date +%Y-%m-%d)" user_data/logs/$strategy/freqtrade.log | grep -ic "buy\|sell" || echo "0")
  echo "Trades today: $trades_today"
  
  # Database size
  if [ -f "user_data/logs/$strategy/trades.sqlite" ]; then
    db_size=$(ls -lh "user_data/logs/$strategy/trades.sqlite" | awk '{print $5}')
    echo "Database size: $db_size"
  fi
  
  # Last heartbeat
  last_heartbeat=$(grep "heartbeat" user_data/logs/$strategy/freqtrade.log | tail -1 | cut -d' ' -f1-2)
  echo "Last heartbeat: $last_heartbeat"
done

echo -e "\n=== Container Status ==="
docker compose -f docker-compose-multi.yml ps
EOF

chmod +x daily_report.sh
```

### **Strategy Comparison**
```bash
# Compare strategy activity levels
echo "Strategy Activity Comparison (last 24 hours):"
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  count=$(grep "$(date +%Y-%m-%d)" user_data/logs/$strategy/freqtrade.log 2>/dev/null | wc -l)
  printf "%-15s: %5d log entries\n" "$strategy" "$count"
done

# Database size comparison
echo -e "\nDatabase Size Comparison:"
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  if [ -f "user_data/logs/$strategy/trades.sqlite" ]; then
    size=$(ls -lh "user_data/logs/$strategy/trades.sqlite" | awk '{print $5}')
    printf "%-15s: %8s\n" "$strategy" "$size"
  fi
done
```

---

## 🚨 **Troubleshooting Multi-Strategy Issues**

### **Common Problems & Solutions**

#### **One Strategy Not Responding**
```bash
# Diagnose specific strategy
strategy="SecondStrategy"  # Change as needed

# Check container status
docker compose -f docker-compose-multi.yml ps $strategy

# Check container logs
docker logs freqtrade-second --tail=50

# Check API response
curl -v http://127.0.0.1:8081/api/v1/ping

# Restart if needed
docker compose -f docker-compose-multi.yml restart freqtrade-second
```

#### **No Trading Activity**
```bash
# Check if strategies are receiving market data
for strategy in FirstStrategy SecondStrategy ThirdStrategy; do
  echo "=== $strategy Market Data ==="
  grep -i "refresh\|pairs\|market" user_data/logs/$strategy/freqtrade.log | tail -3
done

# Verify pairlist configuration
docker logs freqtrade-first | grep -i "whitelist" | tail -1
docker logs freqtrade-second | grep -i "whitelist" | tail -1
docker logs freqtrade-third | grep -i "whitelist" | tail -1
```

#### **High Resource Usage**
```bash
# Monitor resource consumption
docker stats --no-stream

# Check for runaway processes
ps aux | grep freqtrade

# Review log file sizes
du -sh user_data/logs/*/freqtrade.log
```

---

## 📋 **Monitoring Checklist**

### **Daily Monitoring Tasks**
- [ ] ✅ All containers running (`docker compose ps`)
- [ ] ✅ APIs responding (curl health checks)
- [ ] ✅ No error spikes in logs
- [ ] ✅ Trading activity appropriate for each strategy
- [ ] ✅ FreqUI accessible and responsive
- [ ] ✅ Log files growing at expected rates

### **Weekly Monitoring Tasks**
- [ ] ✅ Review strategy performance comparison
- [ ] ✅ Check database sizes and cleanup if needed
- [ ] ✅ Analyze trading patterns and profitability
- [ ] ✅ Update strategy parameters if needed
- [ ] ✅ Backup important configurations

---

## 🎯 **Next Steps**

1. **Set up automated monitoring** using the provided scripts
2. **Configure alerts** for critical issues
3. **Review performance** using [Backtest Analysis Guide](BACKTEST_ANALYSIS.md)
4. **Optimize strategies** based on monitoring data

---

**Your multi-strategy monitoring system is comprehensive and ready for professional trading operations! 📊** 