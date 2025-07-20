# 🎯 Unified FreqUI - Multi-Strategy Monitoring

## Single Interface for Multiple Independent Strategies

This guide explains how to monitor the **three example strategies provided** from a **single unified interface**. Each strategy runs in its own Docker container with separate processes, but you can view and control all of them from one dashboard.

---

## 🧠 **Understanding the Multi-Container Architecture**

### **Why Separate Containers for Each Strategy?**

| **Benefit** | **Explanation** |
|-------------|-----------------|
| **Isolation** | One strategy crash doesn't affect others |
| **Independent Scaling** | Start/stop/restart strategies individually |
| **Resource Management** | Each strategy gets dedicated resources |
| **Configuration Separation** | Different configs don't interfere |
| **Log Organization** | Separate log files for easier debugging |

### **Container Architecture Diagram**
```
┌─────────────────────────────────────────────────────────────┐
│                    HOST SYSTEM (macOS)                     │
├─────────────────────────────────────────────────────────────┤
│ Container 1 (8080)   │ Container 2 (8081)   │ Container 3 (8082) │
│ ┌─────────────────┐  │ ┌─────────────────┐  │ ┌─────────────────┐ │
│ │ FirstStrategy   │  │ │ SecondStrategy  │  │ │ ThirdStrategy   │ │
│ │ Conservative    │  │ │ Trend Following │  │ │ Scalping        │ │
│ │ RSI + SMA       │  │ │ EMA + MACD      │  │ │ BB + Stochastic │ │
│ │ 5m timeframe    │  │ │ 15m timeframe   │  │ │ 1m timeframe    │ │
│ │ UI: ✅ Main     │  │ │ UI: ❌ API Only │  │ │ UI: ❌ API Only │ │
│ │ API: ✅ Active  │  │ │ API: ✅ Active  │  │ │ API: ✅ Active  │ │
│ └─────────────────┘  │ └─────────────────┘  │ └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
           │                     │                     │
           └─────────────────────┼─────────────────────┘
                                 │ CORS Enabled
                   ┌─────────────▼─────────────┐
                   │     Unified FreqUI        │
                   │  http://127.0.0.1:8080    │
                   │  • All strategy monitoring │
                   │  • Bot switching dropdown │
                   │  • Combined profit view   │
                   └───────────────────────────┘
```

---

## 📊 **Current Configuration Overview**

| **Component** | **Port** | **Role** | **Status** | **Purpose** |
|---------------|----------|----------|------------|-------------|
| **FirstStrategy** | 8080 | **Main UI + API** | ✅ Running | Primary interface + trading |
| **SecondStrategy** | 8081 | **API Only** | ✅ Running | Background trading service |
| **ThirdStrategy** | 8082 | **API Only** | ✅ Running | Background trading service |

### **🔗 CORS Configuration Applied**
All containers are configured with Cross-Origin Resource Sharing to allow the main UI to communicate with all strategy APIs:

```json
"CORS_origins": [
  "http://localhost:8080", "http://127.0.0.1:8080",
  "http://localhost:8081", "http://127.0.0.1:8081", 
  "http://localhost:8082", "http://127.0.0.1:8082"
]
```

---

## 🌐 **Accessing the Unified Interface**

### **Main Access Point**
**http://127.0.0.1:8080** - Single interface for all three strategies

### **Login Credentials**
- **Username**: `freqtrader`
- **Password**: `SuperSecretPassword`
- **Note**: Same credentials work for all strategy APIs

---

## 🎮 **Setting Up Multi-Bot Monitoring**

### **Method 1: Manual Configuration in FreqUI**

1. **Open FreqUI**: Navigate to http://127.0.0.1:8080
2. **Login** with provided credentials
3. **Open Settings** (gear icon in top-right)
4. **Add Bot Instances**:

   **Second Bot (Trend Following):**
   - **Name**: `SecondStrategy (Trend Following)`
   - **URL**: `http://127.0.0.1:8081`
   - **Username**: `freqtrader`
   - **Password**: `SuperSecretPassword`
   
   **Third Bot (Scalping):**
   - **Name**: `ThirdStrategy (Scalping)`
   - **URL**: `http://127.0.0.1:8082`
   - **Username**: `freqtrader`
   - **Password**: `SuperSecretPassword`

5. **Save Configuration**

### **Method 2: Import Configuration File**
Use the pre-configured file: `user_data/freqUI_config.json`

```json
{
  "botConfigs": [
    {
      "name": "FirstStrategy (Conservative)",
      "url": "http://127.0.0.1:8080",
      "username": "freqtrader",
      "password": "SuperSecretPassword",
      "active": true
    },
    {
      "name": "SecondStrategy (Trend Following)", 
      "url": "http://127.0.0.1:8081",
      "username": "freqtrader",
      "password": "SuperSecretPassword",
      "active": true
    },
    {
      "name": "ThirdStrategy (Scalping)",
      "url": "http://127.0.0.1:8082", 
      "username": "freqtrader",
      "password": "SuperSecretPassword",
      "active": true
    }
  ]
}
```

---

## 📋 **Strategy Switching & Management**

### **In FreqUI Interface**
- **Bot Dropdown** - Top-left corner, select active strategy
- **Quick Switching** - Switch between strategies without re-login
- **Combined Views** - Some FreqUI versions support combined dashboards

### **Strategy Details**
| **Strategy** | **Trading Style** | **Timeframe** | **Typical Pairs** | **Risk Level** |
|-------------|-------------------|---------------|-------------------|----------------|
| **FirstStrategy** | Conservative RSI + SMA | 5 minutes | BTC, ETH, ADA | 🟢 Low |
| **SecondStrategy** | EMA + MACD Trend | 15 minutes | SOL, DOT, LINK | 🟡 Medium |
| **ThirdStrategy** | Bollinger Bands Scalp | 1 minute | DOGE, SHIB, XRP | 🔴 High |

---

## 🔍 **Monitoring Multiple Strategies**

### **Container Status Check**
```bash
# View all strategy containers
docker compose -f docker-compose-multi.yml ps

# Expected output:
# freqtrade-first    Up    127.0.0.1:8080->8080/tcp
# freqtrade-second   Up    127.0.0.1:8081->8081/tcp  
# freqtrade-third    Up    127.0.0.1:8082->8082/tcp
```

### **API Health Verification**
```bash
# Test all strategy APIs
curl http://127.0.0.1:8080/api/v1/ping  # FirstStrategy
curl http://127.0.0.1:8081/api/v1/ping  # SecondStrategy
curl http://127.0.0.1:8082/api/v1/ping  # ThirdStrategy

# Expected response: {"status":"pong"}
```

### **Real-time Log Monitoring**
```bash
# Monitor all strategies simultaneously
docker compose -f docker-compose-multi.yml logs -f

# Monitor individual strategies
docker logs -f freqtrade-first   # FirstStrategy logs
docker logs -f freqtrade-second  # SecondStrategy logs
docker logs -f freqtrade-third   # ThirdStrategy logs

# File-based log monitoring
tail -f user_data/logs/FirstStrategy/freqtrade.log
tail -f user_data/logs/SecondStrategy/freqtrade.log
tail -f user_data/logs/ThirdStrategy/freqtrade.log
```

---

## 🎯 **Advanced Monitoring Features**

### **Cross-Strategy Performance Tracking**
- **Combined Profit/Loss** - Total portfolio performance
- **Individual Strategy Performance** - Per-strategy profit tracking
- **Risk Distribution** - Monitor exposure across different strategies
- **Trade Volume Analysis** - Compare activity levels

### **Unified Dashboard Benefits**
- **Single Login** - Access all strategies with one authentication
- **Quick Strategy Comparison** - Switch between strategies instantly
- **Centralized Alerts** - All notifications in one place
- **Portfolio Overview** - Complete trading operation visibility

---

## 🔄 **Container Management Commands**

### **Start All Strategies**
```bash
# Start all containers in background
docker compose -f docker-compose-multi.yml up -d

# Start with log output
docker compose -f docker-compose-multi.yml up
```

### **Stop All Strategies**
```bash
# Graceful shutdown of all containers
docker compose -f docker-compose-multi.yml down
```

### **Individual Container Control**
```bash
# Restart specific strategy
docker compose -f docker-compose-multi.yml restart freqtrade-first
docker compose -f docker-compose-multi.yml restart freqtrade-second
docker compose -f docker-compose-multi.yml restart freqtrade-third

# Stop specific strategy
docker stop freqtrade-first
docker stop freqtrade-second
docker stop freqtrade-third

# Start specific strategy
docker start freqtrade-first
docker start freqtrade-second
docker start freqtrade-third
```

---

## 🚨 **Troubleshooting Multi-Container Setup**

### **Common Issues & Solutions**

#### **Can't See Other Strategies in UI**
**Problem**: Only FirstStrategy visible in dropdown
**Solutions**:
1. Verify API accessibility:
   ```bash
   curl http://127.0.0.1:8081/api/v1/ping
   curl http://127.0.0.1:8082/api/v1/ping
   ```
2. Check CORS configuration in browser console (F12)
3. Manually add bot instances in FreqUI settings
4. Verify all containers are running: `docker compose ps`

#### **CORS Errors in Browser**
**Problem**: Cross-origin requests blocked
**Solutions**:
```bash
# Test CORS headers
curl -H "Origin: http://127.0.0.1:8080" -v http://127.0.0.1:8081/api/v1/ping

# Expected: Access-Control-Allow-Origin header present
```

#### **Authentication Issues**
**Problem**: Login fails for secondary strategies
**Solutions**:
- Verify same credentials: `freqtrader` / `SuperSecretPassword`
- Check JWT secret consistency across all configs
- Clear browser cache and cookies

#### **Container Won't Start**
**Problem**: Individual strategy container fails
**Solutions**:
```bash
# Check container logs
docker logs freqtrade-second

# Verify configuration
docker compose run --rm freqtrade show-config \
  -c /freqtrade/user_data/strategies/SecondStrategy/config_dryrun.json

# Check port conflicts
lsof -i :8081
lsof -i :8082
```

---

## 📊 **Expected Behavior by Strategy**

### **FirstStrategy (Conservative)**
- **Activity Level**: Low (1-3 trades/day)
- **Timeframe**: 5 minutes
- **UI Role**: Main interface + trading
- **Monitoring**: Full dashboard access

### **SecondStrategy (Trend Following)**
- **Activity Level**: Medium (3-6 trades/day)
- **Timeframe**: 15 minutes  
- **UI Role**: API only (accessed via main UI)
- **Monitoring**: Switch to view in dropdown

### **ThirdStrategy (Scalping)**
- **Activity Level**: High (20-50 trades/day)
- **Timeframe**: 1 minute
- **UI Role**: API only (accessed via main UI)
- **Monitoring**: Switch to view in dropdown

---

## ⚡ **Quick Verification Checklist**

Before proceeding to live monitoring:

- [ ] ✅ **All containers running**: `docker compose ps` shows 3 containers
- [ ] ✅ **APIs responding**: All curl tests return 200 status
- [ ] ✅ **UI accessible**: Can login to http://127.0.0.1:8080
- [ ] ✅ **Bot switching works**: Can see multiple bots in dropdown
- [ ] ✅ **CORS functional**: No cross-origin errors in browser console
- [ ] ✅ **Logs active**: All strategies showing heartbeat messages

---

## 🎯 **Next Steps**

1. **Launch Dry Run** - Follow [Dry Run Operations Guide](DRY_RUN_GUIDE.md) to start and stop dry run trading safely
2. **Start Monitoring** - Use [Monitoring Guide](MONITORING_GUIDE.md) for detailed monitoring
3. **Analyze Performance** - Compare strategy performance over time
4. **Optimize Settings** - Adjust individual strategy parameters as needed

---

## 📚 **Related Documentation**

- **[Master Guide](../README.md)** - Complete setup overview
- **[Backtesting Guide](BACKTESTING_GUIDE.md)** - Test before deployment
- **[Monitoring Guide](MONITORING_GUIDE.md)** - Advanced monitoring techniques

---

**Your unified multi-strategy interface is ready! Monitor all three strategies from one powerful dashboard! 🚀** 