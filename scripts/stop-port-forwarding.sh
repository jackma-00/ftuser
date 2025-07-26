#!/bin/bash
set -e

echo "🔌 Stopping port forwarding for all trading strategies..."

# Stop port forwarding processes using stored PIDs
if [ -f .port-forward-pids ]; then
    echo "📋 Found port forwarding processes..."
    while read pid; do
        if ps -p $pid > /dev/null 2>&1; then
            echo "  Killing port-forward process $pid"
            kill $pid 2>/dev/null || true
        else
            echo "  Process $pid already stopped"
        fi
    done < .port-forward-pids
    rm -f .port-forward-pids
    echo "✅ All port forwarding processes stopped"
else
    echo "⚠️  No port forwarding PID file found"
fi

# Also kill any remaining kubectl port-forward processes as backup
if pkill -f "kubectl port-forward.*freqtrade-system" 2>/dev/null; then
    echo "🧹 Cleaned up any remaining port forwarding processes"
fi

echo ""
echo "✅ Port forwarding stopped!"
echo "🚀 To restart: ./scripts/start-port-forwarding.sh" 