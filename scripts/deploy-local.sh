#!/bin/bash
set -e

echo "🚀 Deploying Freqtrade Trading System to Local Kubernetes"

# Check if kind cluster exists
if ! kind get clusters | grep -q freqtrade-local; then
    echo "⚠️  kind cluster 'freqtrade-local' not found. Creating it..."
    kind create cluster --name freqtrade-local --config kind-config.yaml
fi

# Build the operator image
echo "🔨 Building Rust operator..."
cd k8s-operator
docker build -t trading-operator:local .
cd ..

# Load image into kind cluster
echo "📦 Loading operator image into kind cluster..."
kind load docker-image trading-operator:local --name freqtrade-local

# Apply Kubernetes manifests
echo "🎯 Applying Kubernetes manifests..."

# 1. Create namespace
kubectl apply -f k8s-manifests/local/namespace.yaml

# 2. Apply CRD
kubectl apply -f k8s-manifests/base/crd.yaml

# 3. Deploy operator
kubectl apply -f k8s-manifests/local/operator-deployment.yaml

# 4. Wait for operator to be ready
echo "⏳ Waiting for operator to be ready..."
kubectl wait --for=condition=available deployment/trading-operator -n freqtrade-system --timeout=120s

# 5. Deploy strategies
echo "📈 Deploying trading strategies..."
kubectl apply -f k8s-manifests/local/first-strategy.yaml
kubectl apply -f k8s-manifests/local/second-strategy.yaml
kubectl apply -f k8s-manifests/local/third-strategy.yaml

# 6. Wait for strategies to be ready
echo "⏳ Waiting for strategies to be ready..."
kubectl wait --for=condition=available deployment/first-strategy -n freqtrade-system --timeout=180s
kubectl wait --for=condition=available deployment/second-strategy -n freqtrade-system --timeout=180s
kubectl wait --for=condition=available deployment/third-strategy -n freqtrade-system --timeout=180s

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Setting up automatic port forwarding..."

# Start port forwarding in background for all strategies
kubectl port-forward -n freqtrade-system svc/first-strategy 8080:8080 > /dev/null 2>&1 &
FIRST_PID=$!
echo "FirstStrategy: http://localhost:8080 (PID: $FIRST_PID)"

kubectl port-forward -n freqtrade-system svc/second-strategy 8081:8081 > /dev/null 2>&1 &
SECOND_PID=$!
echo "SecondStrategy: http://localhost:8081 (PID: $SECOND_PID)"

kubectl port-forward -n freqtrade-system svc/third-strategy 8082:8082 > /dev/null 2>&1 &
THIRD_PID=$!
echo "ThirdStrategy: http://localhost:8082 (PID: $THIRD_PID)"

# Store PIDs for cleanup
echo "$FIRST_PID" > .port-forward-pids
echo "$SECOND_PID" >> .port-forward-pids
echo "$THIRD_PID" >> .port-forward-pids

# Wait a moment for port forwarding to establish
sleep 3

echo ""
echo "🎉 All services are now accessible!"
echo ""
echo "📊 Access your trading strategies:"
echo "  🔗 FirstStrategy:  http://localhost:8080 (Username: freqtrader, Password: SuperSecretPassword)"
echo "  🔗 SecondStrategy: http://localhost:8081 (Username: freqtrader, Password: SuperSecretPassword)"
echo "  🔗 ThirdStrategy:  http://localhost:8082 (Username: freqtrader, Password: SuperSecretPassword)"
echo ""
echo "📊 Check status:"
echo "  kubectl get tradingstrategies -n freqtrade-system"
echo "  kubectl get pods -n freqtrade-system"
echo ""
echo "📝 View logs (equivalent to docker logs):"
echo "  kubectl logs -n freqtrade-system deployment/first-strategy -f"
echo "  kubectl logs -n freqtrade-system deployment/second-strategy -f"
echo "  kubectl logs -n freqtrade-system deployment/third-strategy -f"
echo "  kubectl logs -n freqtrade-system deployment/trading-operator -f"
echo ""
echo "🔄 Common operations (equivalent to docker-compose commands):"
echo "  # Start/Stop equivalent:"
echo "  kubectl scale deployment first-strategy --replicas=0 -n freqtrade-system  # Stop"
echo "  kubectl scale deployment first-strategy --replicas=1 -n freqtrade-system  # Start"
echo ""
echo "  # Status check equivalent to 'docker-compose ps':"
echo "  kubectl get pods -n freqtrade-system -o wide" 