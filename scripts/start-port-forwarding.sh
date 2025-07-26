#!/bin/bash
set -e

echo "🌐 Starting port forwarding for all trading strategies..."

# Check if services exist
if ! kubectl get svc -n freqtrade-system | grep -q first-strategy; then
    echo "❌ Trading strategies not deployed. Run ./scripts/deploy-local.sh first."
    exit 1
fi

# Kill existing port forwarding if running
if [ -f .port-forward-pids ]; then
    echo "🔌 Stopping existing port forwarding..."
    while read pid; do
        kill $pid 2>/dev/null || true
    done < .port-forward-pids
    rm -f .port-forward-pids
fi

# Start port forwarding for all strategies
kubectl port-forward -n freqtrade-system svc/first-strategy 8080:8080 > /dev/null 2>&1 &
FIRST_PID=$!
echo "FirstStrategy: http://localhost:8080 (PID: $FIRST_PID)"

kubectl port-forward -n freqtrade-system svc/second-strategy 8081:8081 > /dev/null 2>&1 &
SECOND_PID=$!
echo "SecondStrategy: http://localhost:8081 (PID: $SECOND_PID)"

kubectl port-forward -n freqtrade-system svc/third-strategy 8082:8082 > /dev/null 2>&1 &
THIRD_PID=$!
echo "ThirdStrategy: http://localhost:8082 (PID: $THIRD_PID)"

# Store PIDs
echo "$FIRST_PID" > .port-forward-pids
echo "$SECOND_PID" >> .port-forward-pids
echo "$THIRD_PID" >> .port-forward-pids

# Wait for connections to establish
sleep 3

echo ""
echo "🎉 Port forwarding active! Access your strategies:"
echo "  🔗 FirstStrategy:  http://localhost:8080"
echo "  🔗 SecondStrategy: http://localhost:8081"
echo "  🔗 ThirdStrategy:  http://localhost:8082"
echo ""
echo "📝 Username: freqtrader | Password: SuperSecretPassword"
echo ""
echo "⏹️  To stop port forwarding: ./scripts/stop-port-forwarding.sh" 