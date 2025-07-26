# 🚀 Freqtrade Kubernetes Command Guide

## Quick Start/Stop Commands

### 🏁 **Start Everything**
```bash
# Deploy entire trading system with automatic port forwarding
./scripts/deploy-local.sh
```
**Result:** All strategies running + automatic port forwarding to:
- FirstStrategy: http://localhost:8080
- SecondStrategy: http://localhost:8081  
- ThirdStrategy: http://localhost:8082

---

### 🛑 **Stop Everything**
```bash
# Complete cleanup - stops all services and removes cluster
./scripts/cleanup-local.sh
```

---

## Port Forwarding Management

### 🌐 **Start Port Forwarding Only**
```bash
# If strategies are running but port forwarding stopped
./scripts/start-port-forwarding.sh
```

### 🔌 **Stop Port Forwarding Only**
```bash
# Keep strategies running but stop port forwarding
./scripts/stop-port-forwarding.sh
```

---

## Individual Strategy Management

### 📊 **Check Status**
```bash
# View all pods
kubectl get pods -n freqtrade-system

# View all strategies  
kubectl get tradingstrategies -n freqtrade-system

# View services
kubectl get services -n freqtrade-system
```

### 🔄 **Start/Stop Individual Strategies**
```bash
# Stop a strategy
kubectl scale deployment first-strategy --replicas=0 -n freqtrade-system
kubectl scale deployment second-strategy --replicas=0 -n freqtrade-system
kubectl scale deployment third-strategy --replicas=0 -n freqtrade-system

# Start a strategy
kubectl scale deployment first-strategy --replicas=1 -n freqtrade-system
kubectl scale deployment second-strategy --replicas=1 -n freqtrade-system
kubectl scale deployment third-strategy --replicas=1 -n freqtrade-system
```

### 🔄 **Restart Individual Strategies**
```bash
# Restart strategies (useful after config changes)
kubectl rollout restart deployment first-strategy -n freqtrade-system
kubectl rollout restart deployment second-strategy -n freqtrade-system
kubectl rollout restart deployment third-strategy -n freqtrade-system
```

---

## Logs and Monitoring

### 📝 **View Logs**
```bash
# Live logs (equivalent to docker logs -f)
kubectl logs -n freqtrade-system deployment/first-strategy -f
kubectl logs -n freqtrade-system deployment/second-strategy -f
kubectl logs -n freqtrade-system deployment/third-strategy -f

# Operator logs
kubectl logs -n freqtrade-system deployment/trading-operator -f

# Recent logs (last 50 lines)
kubectl logs -n freqtrade-system deployment/first-strategy --tail=50
```

### 🔍 **Debug Commands**
```bash
# Describe a pod for troubleshooting
kubectl describe pod -n freqtrade-system -l app=first-strategy

# Get events
kubectl get events -n freqtrade-system --sort-by='.metadata.creationTimestamp'

# Shell into a running container
kubectl exec -it deployment/first-strategy -n freqtrade-system -- /bin/bash
```

---

## Access URLs

### 🌐 **Trading Interfaces**
- **FirstStrategy**: http://localhost:8080
- **SecondStrategy**: http://localhost:8081
- **ThirdStrategy**: http://localhost:8082

**Login:** Username: `freqtrader` | Password: `SuperSecretPassword`

### 📱 **Manual Port Forwarding** (if automatic fails)
```bash
# Run these in separate terminals
kubectl port-forward -n freqtrade-system svc/first-strategy 8080:8080
kubectl port-forward -n freqtrade-system svc/second-strategy 8081:8081  
kubectl port-forward -n freqtrade-system svc/third-strategy 8082:8082
```

---

## Configuration Management

### ⚙️ **Update Strategy Configurations**
```bash
# Edit strategy configs in user_data/strategies/
# Then restart the specific strategy:
kubectl rollout restart deployment first-strategy -n freqtrade-system
```

### 🆕 **Add New Strategy**
1. Create new strategy folder in `user_data/strategies/NewStrategy/`
2. Add config files: `config_dryrun.json`, `NewStrategy.py`
3. Create new Kubernetes manifest: `k8s-manifests/local/new-strategy.yaml`
4. Apply: `kubectl apply -f k8s-manifests/local/new-strategy.yaml`

---

## Development Commands

### 🔨 **Rebuild Operator**
```bash
# After making changes to k8s-operator/src/main.rs
cd k8s-operator
docker build -t trading-operator:local .
kind load docker-image trading-operator:local --name freqtrade-local
kubectl rollout restart deployment trading-operator -n freqtrade-system
cd ..
```

### 🧪 **Test Connection**
```bash
# Test if services are responding
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
curl -s -o /dev/null -w "%{http_code}" http://localhost:8081  
curl -s -o /dev/null -w "%{http_code}" http://localhost:8082
```

---

## Troubleshooting

### ❌ **Common Issues**

**Port forwarding not working:**
```bash
./scripts/stop-port-forwarding.sh
./scripts/start-port-forwarding.sh
```

**Strategies not starting:**
```bash
# Check logs
kubectl logs -n freqtrade-system deployment/first-strategy --tail=100

# Check if volume mounted correctly
kubectl describe pod -n freqtrade-system -l app=first-strategy
```

**Complete reset:**
```bash
./scripts/cleanup-local.sh
./scripts/deploy-local.sh
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| **Start All** | `./scripts/deploy-local.sh` |
| **Stop All** | `./scripts/cleanup-local.sh` |
| **Port Forward** | `./scripts/start-port-forwarding.sh` |
| **Stop Port Forward** | `./scripts/stop-port-forwarding.sh` |
| **View Status** | `kubectl get pods -n freqtrade-system` |
| **View Logs** | `kubectl logs -n freqtrade-system deployment/first-strategy -f` |
| **Restart Strategy** | `kubectl rollout restart deployment first-strategy -n freqtrade-system` |

---

## 🎯 **Daily Workflow**

1. **Start:** `./scripts/deploy-local.sh`
2. **Trade:** Open http://localhost:8080, 8081, 8082
3. **Monitor:** `kubectl logs -n freqtrade-system deployment/first-strategy -f`
4. **Stop:** `./scripts/cleanup-local.sh` 