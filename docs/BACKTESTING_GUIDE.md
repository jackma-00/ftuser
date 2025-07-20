# 📊 Multi-Strategy Backtesting Guide

## Understanding Backtesting in Multi-Strategy Setup

This guide shows how to run organized backtests for **multiple independent strategies** before deploying them in live trading. While these concepts apply to any multi-strategy setup, this guide will specifically focus on the **three example strategies provided** (FirstStrategy, SecondStrategy, and ThirdStrategy). **Backtesting uses StaticPairList** for consistent historical testing, while live trading uses **VolumePairList** for dynamic pair selection.

---

## 🧠 **Key Concept: StaticPairList vs VolumePairList**

### **Why Different Pairlists for Backtesting vs Live Trading?**

| **Aspect** | **StaticPairList (Backtesting)** | **VolumePairList (Live Trading)** |
|------------|-----------------------------------|-----------------------------------|
| **Purpose** | Historical testing with fixed pairs | Dynamic trading with active pairs |
| **Pairs** | Fixed list (e.g., BTC/USDT, ETH/USDT) | Auto-selected by volume |
| **Consistency** | Same pairs throughout test period | Changes based on market activity |
| **Use Case** | Reliable backtesting results | Adapts to market conditions |

### **Configuration Examples:**

**Backtesting Config (`config_backtest.json`):**
```json
"pairlists": [
    {
        "method": "StaticPairList"
    }
],
"pair_whitelist": [
    "BTC/USDT", "ETH/USDT", "ADA/USDT"
]
```

**Live Trading Config (`config_dryrun.json`):**
```json
"pairlists": [
    {
        "method": "VolumePairList",
        "number_assets": 15,
        "sort_key": "quoteVolume"
    },
    {
        "method": "AgeFilter",
        "min_days_listed": 10
    }
]
```

---

## 📥 **Download Market Data for Your Strategies**

Before running backtests, you need to download historical market data for each strategy's specific pairs and timeframes.

### **Data Requirements by Strategy**

| **Strategy** | **Timeframe** | **Pairs** | **Data Period** |
|-------------|---------------|-----------|-----------------|
| **FirstStrategy** | 5 minutes | BTC/USDT, ETH/USDT, ADA/USDT | 3-6 months |
| **SecondStrategy** | 15 minutes | SOL/USDT, DOT/USDT, LINK/USDT | 3-6 months |
| **ThirdStrategy** | 1 minute | DOGE/USDT, SHIB/USDT, XRP/USDT, TRX/USDT, LTC/USDT | 1-2 months |

### **Download Commands for Each Strategy**

#### **FirstStrategy Data (Conservative RSI + SMA)**
```bash
# Download 6 months of 5-minute data for conservative strategy
docker compose run --rm freqtrade download-data \
  --config user_data/strategies/FirstStrategy/config_backtest.json \
  --pairs BTC/USDT ETH/USDT ADA/USDT \
  --timeframe 5m \
  --timerange 20240301-20240901 \
  --exchange binance
```

#### **SecondStrategy Data (EMA + MACD Trend)**
```bash
# Download 6 months of 15-minute data for trend following
docker compose run --rm freqtrade download-data \
  --config user_data/strategies/SecondStrategy/config_backtest.json \
  --pairs SOL/USDT DOT/USDT LINK/USDT \
  --timeframe 15m \
  --timerange 20240301-20240901 \
  --exchange binance
```

#### **ThirdStrategy Data (Bollinger Bands Scalping)**
```bash
# Download 2 months of 1-minute data for scalping (large dataset)
docker compose run --rm freqtrade download-data \
  --config user_data/strategies/ThirdStrategy/config_backtest.json \
  --pairs DOGE/USDT SHIB/USDT XRP/USDT TRX/USDT LTC/USDT \
  --timeframe 1m \
  --timerange 20240701-20240901 \
  --exchange binance
```

### **Download All Strategy Data at Once**
```bash
# Download data for all strategies in one command
docker compose run --rm freqtrade download-data \
  --pairs BTC/USDT ETH/USDT ADA/USDT SOL/USDT DOT/USDT LINK/USDT DOGE/USDT SHIB/USDT XRP/USDT TRX/USDT LTC/USDT \
  --timeframes 1m 5m 15m \
  --timerange 20240301-20240901 \
  --exchange binance
```

### **Data Storage Location**
```
user_data/data/binance/
├── ADA_USDT-5m.json       # FirstStrategy data
├── BTC_USDT-5m.json
├── ETH_USDT-5m.json
├── SOL_USDT-15m.json      # SecondStrategy data  
├── DOT_USDT-15m.json
├── LINK_USDT-15m.json
├── DOGE_USDT-1m.json      # ThirdStrategy data
├── SHIB_USDT-1m.json
├── XRP_USDT-1m.json
├── TRX_USDT-1m.json
└── LTC_USDT-1m.json
```

### **Verify Downloaded Data**
```bash
# Check available data for your strategies
docker compose run --rm freqtrade list-data \
  --config user_data/strategies/FirstStrategy/config_backtest.json

# Show data summary
docker compose run --rm freqtrade show-trades \
  --config user_data/strategies/FirstStrategy/config_backtest.json \
  --print-json | head -20
```

### **Data Download Best Practices**
- **Start Small**: Download 1-2 months initially to test
- **Expand Gradually**: Add more historical data as needed
- **Storage Space**: 1-minute data requires significantly more storage
- **Network**: Large downloads may take 10-30 minutes
- **Exchange Limits**: Binance allows reasonable download rates

---

## 🎯 **Multi-Strategy Directory Structure**

```
user_data/
├── backtest_results/           # Organized results by strategy
│   ├── FirstStrategy/          # Conservative RSI + SMA results
│   ├── SecondStrategy/         # EMA + MACD Trend Following results
│   └── ThirdStrategy/          # Bollinger Bands Scalping results
├── strategies/                 # Each strategy in its own folder
│   ├── FirstStrategy/
│   │   ├── FirstStrategy.py           # Strategy code
│   │   ├── config_backtest.json       # StaticPairList config
│   │   └── config_dryrun.json         # VolumePairList config
│   ├── SecondStrategy/
│   │   ├── SecondStrategy.py
│   │   ├── config_backtest.json
│   │   └── config_dryrun.json
│   └── ThirdStrategy/
│       ├── ThirdStrategy.py
│       ├── config_backtest.json
│       └── config_dryrun.json
└── logs/                       # Organized logs by strategy
    ├── FirstStrategy/
    ├── SecondStrategy/
    └── ThirdStrategy/
```

---

## 🚀 **Quick Start: Test All Strategies**

### **Option 1: Automated Script**
```bash
# Run all strategies with organized results
./backtest_all_strategies.sh
```

### **Option 2: Individual Strategy Backtesting**

### **FirstStrategy (Conservative RSI + SMA)**
**Timeframe:** 5 minutes | **Pairs:** BTC/USDT, ETH/USDT, ADA/USDT

```bash
# Full month test using StaticPairList
docker compose run --rm freqtrade backtesting \
  --config user_data/strategies/FirstStrategy/config_backtest.json \
  --strategy FirstStrategy \
  --strategy-path user_data/strategies/FirstStrategy \
  --timerange 20240801-20240901 \
  --export signals \
  --export-filename "user_data/backtest_results/FirstStrategy/FirstStrategy_$(date +%Y%m%d_%H%M%S)" \
  --cache none
```

### **SecondStrategy (EMA + MACD Trend Following)**
**Timeframe:** 15 minutes | **Pairs:** SOL/USDT, DOT/USDT, LINK/USDT

```bash
# Full month test for trend following
docker compose run --rm freqtrade backtesting \
  --config user_data/strategies/SecondStrategy/config_backtest.json \
  --strategy SecondStrategy \
  --strategy-path user_data/strategies/SecondStrategy \
  --timerange 20240801-20240901 \
  --export signals \
  --export-filename "user_data/backtest_results/SecondStrategy/SecondStrategy_$(date +%Y%m%d_%H%M%S)" \
  --cache none
```

### **ThirdStrategy (Bollinger Bands Scalping)**
**Timeframe:** 1 minute | **Pairs:** DOGE/USDT, SHIB/USDT, XRP/USDT, TRX/USDT, LTC/USDT

```bash
# Shorter period for high-frequency strategy
docker compose run --rm freqtrade backtesting \
  --config user_data/strategies/ThirdStrategy/config_backtest.json \
  --strategy ThirdStrategy \
  --strategy-path user_data/strategies/ThirdStrategy \
  --timerange 20240801-20240805 \
  --export signals \
  --export-filename "user_data/backtest_results/ThirdStrategy/ThirdStrategy_$(date +%Y%m%d_%H%M%S)" \
  --cache none
```

---

## 📈 **Testing Different Market Conditions**

### **Market Period Selection**
```bash
# Bull Market Period
--timerange 20240301-20240331

# Bear Market Period  
--timerange 20240801-20240831

# Volatile Period
--timerange 20240601-20240630

# Extended Test (3 months)
--timerange 20240501-20240801
```

### **Strategy-Specific Testing Periods**
```bash
# Conservative Strategy - Longer periods
--timerange 20240101-20240331

# Trend Following - Medium periods
--timerange 20240401-20240630

# Scalping - Shorter periods (high frequency)
--timerange 20240801-20240810
```

---

## 📊 **Understanding Backtest Results**

### **Key Metrics to Analyze**
- **Total Profit %** - Overall strategy profitability
- **Win Rate** - Percentage of profitable trades
- **Avg Trade Duration** - How long positions are held
- **Max Drawdown** - Largest peak-to-trough loss
- **Sharpe Ratio** - Risk-adjusted returns

### **Strategy-Specific Expectations**

| **Strategy** | **Expected Trades/Day** | **Win Rate** | **Avg Duration** | **Risk Level** |
|-------------|-------------------------|-------------|------------------|----------------|
| **FirstStrategy** | 1-3 trades | 60-70% | 2-4 hours | 🟢 Low |
| **SecondStrategy** | 3-6 trades | 45-55% | 1-3 hours | 🟡 Medium |
| **ThirdStrategy** | 20-50 trades | 35-45% | 5-30 minutes | 🔴 High |

---

## 📁 **Organized Results Structure**

### **Generated Files Per Strategy**
```
user_data/backtest_results/FirstStrategy/
├── FirstStrategy_20240719_150000.json           # Main results
├── FirstStrategy_20240719_150000_signals.pkl    # Entry/Exit signals
└── FirstStrategy_20240719_150000_exited.pkl     # Trade details
```

### **File Types Explained**
- **`.json`** - Main backtest results (trades, profit, metrics)
- **`_signals.pkl`** - Detailed entry/exit signals for analysis
- **`_exited.pkl`** - Detailed trade exit information

---

## 🔍 **Advanced Analysis Commands**

### **Strategy Performance Comparison**
```bash
# Compare all strategies on same period
docker compose run --rm freqtrade backtesting \
  --strategy-list FirstStrategy SecondStrategy ThirdStrategy \
  --recursive-strategy-search \
  --strategy-path user_data/strategies \
  --timerange 20240801-20240831 \
  --export trades \
  --export-filename "user_data/backtest_results/comparison_$(date +%Y%m%d_%H%M%S)"
```

### **Detailed Signal Analysis**
```bash
# Analyze entry/exit signals for specific strategy
docker compose run --rm freqtrade backtesting-analysis \
  --config user_data/strategies/FirstStrategy/config_backtest.json \
  --analysis-groups 0 1 2 3
```

### **Export Results to CSV**
```bash
# Export for Excel analysis
docker compose run --rm freqtrade backtesting-analysis \
  --config user_data/strategies/FirstStrategy/config_backtest.json \
  --analysis-to-csv \
  --analysis-csv-path user_data/backtest_results/FirstStrategy/
```

---

## 🔧 **Advanced Configuration Options**

### **Custom Fee Testing**
```bash
--fee 0.001  # Test with 0.1% trading fee
```

### **Custom Starting Balance**
```bash
--dry-run-wallet 5000  # Start with 5000 USDT
```

### **Force Fresh Analysis**
```bash
--cache none  # Ignore cached results
```

### **Multi-Timeframe Testing**
```bash
# Test multiple timeframes for same strategy
--timeframe 5m  # Then repeat with 15m, 1h
```

---

## 🚨 **Common Issues & Solutions**

### **No Trades in Backtest**
**Problem:** Strategy shows 0 trades
**Solutions:**
- Check if historical data exists for selected pairs
- Verify timerange has sufficient data
- Adjust strategy parameters (RSI thresholds, etc.)
- Download missing data: `freqtrade download-data`

### **VolumePairList Error in Backtesting**
**Problem:** `VolumePairList does not support backtesting`
**Solution:** Use `config_backtest.json` with StaticPairList, not `config_dryrun.json`

### **Missing Historical Data**
**Problem:** Warnings about missing data
**Solution:**
```bash
# Download required data for all strategies
docker compose run --rm freqtrade download-data \
  -c user_data/strategies/FirstStrategy/config_backtest.json \
  --timerange 20240101-20241201
```

---

## 📋 **Pre-Deployment Checklist**

Before moving to live trading, ensure:

- [ ] ✅ **All strategies tested** on different market periods
- [ ] ✅ **Positive results** in at least 2 of 3 strategies
- [ ] ✅ **Understand each strategy's risk profile**
- [ ] ✅ **Results exported** and analyzed
- [ ] ✅ **Strategy parameters optimized**
- [ ] ✅ **Ready for dry-run testing**

---

## 🎯 **Next Steps**

1. **Analyze Results** - Review [Backtest Analysis Guide](BACKTEST_ANALYSIS.md)
2. **Deploy Strategies** - Follow [Unified UI Guide](UNIFIED_UI_GUIDE.md)  
3. **Monitor Performance** - Use [Monitoring Guide](MONITORING_GUIDE.md)

---

**Remember: Backtesting shows historical performance, not future guarantees. Always start with dry-run mode before risking real money! 📊** 