# 🚀 Kubernetes Deployment Guide

## Docker Compose → Kubernetes Migration

This guide shows how to run your Freqtrade multi-strategy system on Kubernetes with a Rust operator, maintaining the exact same functionality as the Docker Compose setup.

---

## 📋 **Command Equivalents**

### **Deployment Commands**

| Docker Compose | Kubernetes |
|----------------|------------|
| `docker compose -f docker-compose-multi.yml up -d` | `./scripts/deploy-local.sh` |
| `docker compose -f docker-compose-multi.yml stop` | `kubectl scale deployment --all --replicas=0 -n freqtrade-system` |
| `docker compose -f docker-compose-multi.yml start` | `kubectl scale deployment --all --replicas=1 -n freqtrade-system` |
| `docker compose -f docker-compose-multi.yml ps` | `kubectl get pods -n freqtrade-system -o wide` |

### **Individual Strategy Management**

| Operation | Docker Compose | Kubernetes |
|-----------|----------------|------------|
| **Stop FirstStrategy** | `docker compose -f docker-compose-multi.yml stop freqtrade-first` | `kubectl scale deployment first-strategy --replicas=0 -n freqtrade-system` |
| **Start FirstStrategy** | `docker compose -f docker-compose-multi.yml start freqtrade-first` | `kubectl scale deployment first-strategy --replicas=1 -n freqtrade-system` |
| **Restart FirstStrategy** | `docker compose -f docker-compose-multi.yml restart freqtrade-first` | `kubectl rollout restart deployment first-strategy -n freqtrade-system` |

### **Accessing Services**

| Service | Docker Compose | Kubernetes |
|---------|----------------|------------|
| **Main UI (FirstStrategy)** | Direct: `http://127.0.0.1:8080` | Port-forward: `kubectl port-forward -n freqtrade-system svc/first-strategy 8080:8080` |
| **SecondStrategy API** | Direct: `http://127.0.0.1:8081` | Port-forward: `kubectl port-forward -n freqtrade-system svc/second-strategy 8081:8081` |
| **ThirdStrategy API** | Direct: `http://127.0.0.1:8082` | Port-forward: `kubectl port-forward -n freqtrade-system svc/third-strategy 8082:8082` |

### **Viewing Logs**

| Docker Compose | Kubernetes |
|----------------|------------|
| `docker logs freqtrade-first -f` | `kubectl logs -n freqtrade-system deployment/first-strategy -f` |
| `docker logs freqtrade-second -f` | `kubectl logs -n freqtrade-system deployment/second-strategy -f` |
| `docker logs freqtrade-third -f` | `kubectl logs -n freqtrade-system deployment/third-strategy -f` |

---

## 🏗️ **Architecture Comparison**

### **Docker Compose Architecture**
```
Host System
├── freqtrade-first (127.0.0.1:8080:8080)   # Main UI + API
├── freqtrade-second (127.0.0.1:8081:8081)  # API Only  
└── freqtrade-third (127.0.0.1:8082:8082)   # API Only
    │
    └── Shared: ./user_data:/freqtrade/user_data
```

### **Kubernetes Architecture**
```
freqtrade-system namespace
├── trading-operator (Rust controller)
├── first-strategy pod (port 8080)   # Main UI + API
├── second-strategy pod (port 8081)  # API Only
└── third-strategy pod (port 8082)   # API Only
    │
    └── Shared: HostPath volume to user_data
```

---

## 🔧 **Configuration Highlights**

### **Preserved Docker Compose Features**
✅ **Exact same commands**: Uses identical freqtrade command arguments  
✅ **Same ports**: 8080 (FirstStrategy), 8081 (SecondStrategy), 8082 (ThirdStrategy)  
✅ **Same configs**: Uses existing `config_dryrun.json` files  
✅ **Same volume structure**: Mounts existing `user_data` directory  
✅ **Same CORS setup**: Strategies can communicate via existing CORS config  
✅ **Same credentials**: `freqtrader:SuperSecretPassword`  

### **Kubernetes Enhancements**
🚀 **Auto-healing**: Pods restart automatically if they crash  
🚀 **Resource limits**: CPU/Memory limits prevent resource exhaustion  
🚀 **Declarative**: Infrastructure defined as code  
🚀 **Scalable**: Easy to add more strategies  
🚀 **Operator-managed**: Rust operator handles complexity  

---

## 📊 **Current Strategy Configuration**

| Strategy | Port | Purpose | Config File | Database |
|----------|------|---------|-------------|----------|
| **FirstStrategy** | 8080 | Main UI + Conservative Trading | `/user_data/strategies/FirstStrategy/config_dryrun.json` | `/user_data/logs/FirstStrategy/trades.sqlite` |
| **SecondStrategy** | 8081 | API + Trend Following | `/user_data/strategies/SecondStrategy/config_dryrun.json` | `/user_data/logs/SecondStrategy/trades.sqlite` |
| **ThirdStrategy** | 8082 | API + Scalping | `/user_data/strategies/ThirdStrategy/config_dryrun.json` | `/user_data/logs/ThirdStrategy/trades.sqlite` |

---

## 🚀 **Quick Start**

### **1. Deploy Everything**
```bash
./scripts/deploy-local.sh
```

### **2. Access Main UI**
```bash
# Start port forwarding
kubectl port-forward -n freqtrade-system svc/first-strategy 8080:8080

# Open browser to http://127.0.0.1:8080
# Login: freqtrader / SuperSecretPassword
```

### **3. Add SecondStrategy and ThirdStrategy to UI**
In FreqUI settings, add these bot instances:
- **SecondStrategy**: `http://127.0.0.1:8081` (requires port-forward first)
- **ThirdStrategy**: `http://127.0.0.1:8082` (requires port-forward first)

### **4. Monitor All Strategies**
```bash
# Watch pods
kubectl get pods -n freqtrade-system -w

# Stream logs from all strategies
kubectl logs -n freqtrade-system -l managed-by=trading-operator -f
```

---

## 🔄 **Adding New Strategies**

### **Docker Compose Method (Current)**
1. Copy strategy directory to `user_data/strategies/NewStrategy/`
2. Update `docker-compose-multi.yml`
3. Add new service with new port
4. Restart containers

### **Kubernetes Method (New)**
```bash
# Just create a new TradingStrategy resource
kubectl apply -f - <<EOF
apiVersion: trading.io/v1
kind: TradingStrategy
metadata:
  name: new-strategy
  namespace: freqtrade-system
spec:
  name: "new-strategy"
  strategy_class: "NewStrategy"
  image: "freqtradeorg/freqtrade:stable"
  port: 8083
  resources:
    cpu: "2000m"
    memory: "2Gi"
EOF

# The Rust operator automatically creates everything!
```

---

## 🧹 **Cleanup**

### **Stop Everything**
```bash
./scripts/cleanup-local.sh
```

### **Or Stop Individual Services**
```bash
kubectl delete tradingstrategy first-strategy -n freqtrade-system
kubectl delete tradingstrategy second-strategy -n freqtrade-system  
kubectl delete tradingstrategy third-strategy -n freqtrade-system
```

---

## 🔍 **Troubleshooting**

### **Check Status**
```bash
# Overall status
kubectl get all -n freqtrade-system

# Strategy status
kubectl get tradingstrategies -n freqtrade-system

# Pod details
kubectl describe pods -n freqtrade-system
```

### **Common Issues**
| Issue | Solution |
|-------|----------|
| **Pods not starting** | Check: `kubectl logs -n freqtrade-system deployment/trading-operator` |
| **Can't access UI** | Ensure port-forward is running: `kubectl port-forward -n freqtrade-system svc/first-strategy 8080:8080` |
| **Config not found** | Verify HostPath volume points to correct user_data directory |
| **Permission denied** | Check that user_data directory is readable by container |

---

**🎯 Result**: You now have the same 3-strategy setup running on Kubernetes with a Rust operator managing everything automatically! 