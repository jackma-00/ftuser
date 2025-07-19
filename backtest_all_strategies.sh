#!/bin/bash

# Freqtrade Backtesting Script for All Strategies
# This script runs backtests for all strategies and saves results separately

echo "🚀 Starting backtesting for all strategies..."

# Get current date for filename
DATE=$(date +"%Y%m%d_%H%M%S")

# FirstStrategy - Conservative RSI + SMA (5m timeframe)
echo "📊 Testing FirstStrategy..."
docker compose run --rm freqtrade backtesting \
  --config user_data/strategies/FirstStrategy/config_backtest.json \
  --strategy FirstStrategy \
  --strategy-path user_data/strategies/FirstStrategy \
  --timerange 20240801-20240901 \
  --export signals \
  --export-filename "user_data/backtest_results/FirstStrategy/FirstStrategy_${DATE}" \
  --cache none

# SecondStrategy - EMA + MACD Trend Following (15m timeframe)  
echo "📊 Testing SecondStrategy..."
docker compose run --rm freqtrade backtesting \
  --config user_data/strategies/SecondStrategy/config_backtest.json \
  --strategy SecondStrategy \
  --strategy-path user_data/strategies/SecondStrategy \
  --timerange 20240801-20240901 \
  --export signals \
  --export-filename "user_data/backtest_results/SecondStrategy/SecondStrategy_${DATE}" \
  --cache none

# ThirdStrategy - Bollinger Bands Scalping (1m timeframe)
echo "📊 Testing ThirdStrategy..."
docker compose run --rm freqtrade backtesting \
  --config user_data/strategies/ThirdStrategy/config_backtest.json \
  --strategy ThirdStrategy \
  --strategy-path user_data/strategies/ThirdStrategy \
  --timerange 20240801-20240805 \
  --export signals \
  --export-filename "user_data/backtest_results/ThirdStrategy/ThirdStrategy_${DATE}" \
  --cache none

echo "✅ All backtests completed! Results saved to:"
echo "   📁 user_data/backtest_results/FirstStrategy/"
echo "   📁 user_data/backtest_results/SecondStrategy/"
echo "   📁 user_data/backtest_results/ThirdStrategy/" 