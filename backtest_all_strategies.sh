#!/bin/bash

# Freqtrade Backtesting Script for All Strategies
# This script runs backtests for all strategies and saves results separately

echo "🚀 Starting backtesting for all strategies..."

# Get current date for filename
DATE=$(date +"%Y%m%d_%H%M%S")

# FirstStrategy - Conservative RSI + SMA (5m timeframe)
echo "📊 Testing FirstStrategy..."
docker compose run --rm freqtrade-first backtesting \
  --config user_data/strategies/FirstStrategy/config_backtest.json \
  --strategy FirstStrategy \
  --strategy-path user_data/strategies/FirstStrategy \
  --timerange 20240801-20240901 \
  --export signals \
  --export-filename "user_data/backtest_results/FirstStrategy/FirstStrategy_${DATE}" \
  --cache none

echo "✅ All backtests completed! Results saved to:"
echo "   📁 user_data/backtest_results/FirstStrategy/"
