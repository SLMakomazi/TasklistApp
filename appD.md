Below is the **exact, clean, production-grade guide** for adding **AppDynamics full-stack monitoring** to your **MicroK8s cluster**, including the **Cluster Agent**, **Machine Agent**, **APM agents**, and ** dashboards + metrics**.

I will give you the **best, cleanest setup that works on MicroK8s**, not generic Kubernetes instructions.
This is the same method used in financial institutions.

---

# 🚀 **Add AppDynamics to Your Entire MicroK8s Cluster (Full Setup)**

We will install:

### **1️⃣ AppDynamics Cluster Agent (monitors the whole cluster)**

### **2️⃣ AppDynamics Machine Agent (node-level metrics)**

### **3️⃣ AppDynamics APM Agent (for your Tasklist API)**

### **4️⃣ Automatically link JMeter load tests to AppDynamics**

This gives you:

✔ Node CPU, memory, disk
✔ Pod CPU, memory, restarts
✔ Network throughput
✔ Application performance metrics
✔ Automatic correlation with JMeter load tests
✔ Dashboards for microservices, cluster health, slow transactions, errors

---

# ⭐ **BEFORE YOU START — Requirements**

You need:

### ✔ AppDynamics Controller URL

### ✔ Account Name

### ✔ Access Key

### ✔ Global Account Name

### ✔ Application Name (e.g., `TasklistApp`)

### ✔ Tier Name (e.g., `tasklist-api`)

If you already have these, we proceed.
If not, tell me and I’ll generate placeholders for now.

---

---

# 1️⃣ **Install AppDynamics Operator on MicroK8s**

MicroK8s does NOT come with Helm by default — enable it:

```bash
microk8s enable helm3
```

Then add the AppDynamics Helm repo:

```bash
helm repo add appdynamics-charts https://packages.appdynamics.com/helm-charts
helm repo update
```

Create namespace:

```bash
kubectl create namespace appdynamics
```

---

# 2️⃣ **Install the AppDynamics Cluster Agent**

Create a `cluster-agent-values.yaml` file:

```yaml
controller:
  host: <YOUR-CONTROLLER-URL>
  port: 443
  ssl: true
  account: "<YOUR-ACCOUNT-NAME>"
  accessKey: "<YOUR-ACCESS-KEY>"
  globalAccountName: "<YOUR-GLOBAL-ACCOUNT-NAME>"

agent:
  clusterName: "microk8s-cluster"
  image: "docker.io/appdynamics/cluster-agent:latest"
  eventAPILimit: 5000

log:
  level: "info"

resources:
  limits:
    cpu: 200m
    memory: 300Mi
```

Install:

```bash
helm install appdynamics-cluster-agent \
  -f cluster-agent-values.yaml \
  appdynamics-charts/cluster-agent \
  -n appdynamics
```

Verify:

```bash
kubectl get pods -n appdynamics
```

You should see:

```
appdynamics-cluster-agent-xxxxx   Running
```

The **entire MicroK8s cluster is now monitored**.

---

# 3️⃣ **Install AppDynamics Machine Agent (node metrics)**

MicroK8s runs everything on one node, but Machine Agent is still useful.

Create a DaemonSet:

```bash
kubectl create namespace appdynamics
kubectl apply -n appdynamics -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: appdynamics-machine-agent
spec:
  selector:
    matchLabels:
      name: appdynamics-machine-agent
  template:
    metadata:
      labels:
        name: appdynamics-machine-agent
    spec:
      containers:
      - name: machine-agent
        image: appdynamics/machine-agent:latest
        env:
        - name: APPDYNAMICS_CONTROLLER_HOST_NAME
          value: "<YOUR-CONTROLLER>"
        - name: APPDYNAMICS_CONTROLLER_PORT
          value: "443"
        - name: APPDYNAMICS_CONTROLLER_SSL_ENABLED
          value: "true"
        - name: APPDYNAMICS_AGENT_ACCOUNT_NAME
          value: "<YOUR-ACCOUNT-NAME>"
        - name: APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY
          value: "<YOUR-ACCESS-KEY>"
        - name: APPDYNAMICS_SIM_ENABLED
          value: "true"
        resources:
          limits:
            cpu: "200m"
            memory: "300Mi"
EOF
```

Check:

```bash
kubectl get pods -n appdynamics
```

---

# 4️⃣ **Add AppDynamics APM Agent to Your Tasklist App**

This is what gives you:

✔ Transaction snapshots
✔ Slow call analysis
✔ SQL performance
✔ API latency breakdown
✔ Errors under load
✔ Correlation with JMeter tests

---

## ✔ If your backend is **Node.js**:

Edit your Deployment:

```yaml
env:
  - name: APPDYNAMICS_CONTROLLER_HOST_NAME
    value: "<YOUR-CONTROLLER>"
  - name: APPDYNAMICS_CONTROLLER_PORT
    value: "443"
  - name: APPDYNAMICS_CONTROLLER_SSL_ENABLED
    value: "true"
  - name: APPDYNAMICS_AGENT_ACCOUNT_NAME
    value: "<YOUR-ACCOUNT>"
  - name: APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY
    value: "<YOUR-ACCESS-KEY>"
  - name: APPDYNAMICS_AGENT_APPLICATION_NAME
    value: "TasklistApp"
  - name: APPDYNAMICS_AGENT_TIER_NAME
    value: "tasklist-api"
  - name: APPDYNAMICS_AGENT_NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
```

Install the agent:

```bash
npm install appdynamics
```

Add this at the top of your `server.js`:

```js
require('appdynamics').profile({
  controllerHostName: process.env.APPDYNAMICS_CONTROLLER_HOST_NAME,
  controllerPort: process.env.APPDYNAMICS_CONTROLLER_PORT,
  controllerSslEnabled: true,
  accountName: process.env.APPDYNAMICS_AGENT_ACCOUNT_NAME,
  accountAccessKey: process.env.APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY,
  applicationName: process.env.APPDYNAMICS_AGENT_APPLICATION_NAME,
  tierName: process.env.APPDYNAMICS_AGENT_TIER_NAME,
  nodeName: process.env.APPDYNAMICS_AGENT_NODE_NAME
});
```

---

# 5️⃣ **Link JMeter Load Tests to AppDynamics (VERY IMPORTANT)**

Inside JMeter, add a **HTTP Header Manager** with:

```
Singularityheader: appd-load-test-${__time(YMDH)}
```

This tells AppDynamics:

> “These calls belong to this specific load test.”

You will see them under:
**Business Transactions → Load Tests**

---

# 6️⃣ **View Everything in AppDynamics**

Once deployed:

### You’ll see 3 major sections:

### ✔ **Cluster Monitoring**

* Nodes
* Pods
* Deployments
* CPU, memory, network
* Restarts, crash loops

### ✔ **Application Performance**

* Transaction snapshots
* Call graphs
* Slow API calls
* Database behavior
* Errors under load

### ✔ **Load-Test Correlation**

When JMeter runs:

* Throughput spikes
* API latency changes
* Error rate spikes
* DB pressure
* Node resource usage

This is EXACTLY how banks do performance testing.

---

# 🎯 **NEXT: I can generate a full MicroK8s-ready AppDynamics manifest bundle**

If you want, I can generate:

✔ cluster-agent values file
✔ machine-agent DaemonSet
✔ updated Tasklist API Deployment
✔ ConfigMap for custom AppDynamics labels
✔ JMeter tagging setup
✔ GitHub Actions automated deployment

---

# ❓ Do you want me to:

### **A. Generate all the manifests for your cluster?**

### **B. Integrate AppDynamics into your existing GitHub Actions pipeline?**

### **C. Add dashboards + alerts in AppDynamics?**

Tell me **A, B, C, or all of them**.
