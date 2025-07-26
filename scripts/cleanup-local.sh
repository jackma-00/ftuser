#!/bin/bash
set -e

echo "🧹 Cleaning up Freqtrade Trading System"

# Stop port forwarding processes
if [ -f .port-forward-pids ]; then
    echo "🔌 Stopping port forwarding processes..."
    while read pid; do
        if ps -p $pid > /dev/null 2>&1; then
            echo "  Killing port-forward process $pid"
            kill $pid 2>/dev/null || true
        fi
    done < .port-forward-pids
    rm -f .port-forward-pids
fi

# Also kill any kubectl port-forward processes as backup
pkill -f "kubectl port-forward.*freqtrade-system" 2>/dev/null || true

# Delete all resources in the namespace
echo "🗑️  Deleting trading strategies..."
kubectl delete tradingstrategies --all -n freqtrade-system 2>/dev/null || true

echo "🗑️  Deleting namespace..."
kubectl delete namespace freqtrade-system 2>/dev/null || true

echo "🗑️  Deleting CRD..."
kubectl delete crd tradingstrategies.trading.io 2>/dev/null || true

echo "🗑️  Deleting kind cluster..."
kind delete cluster --name freqtrade-local 2>/dev/null || true

echo "✅ Cleanup complete!" 