# 🚀 TasklistApp - Complete Development Environment Setup

A comprehensive guide to setting up the complete TasklistApp development environment, including WSL2, MicroK8s, ArgoCD, CI/CD pipeline, and the application stack.

## 🖥️ System Requirements

- Windows 10/11 with WSL2 enabled
- At least 8GB RAM (16GB recommended)
- At least 20GB free disk space
- Virtualization enabled in BIOS

## 📋 Prerequisites

1. **Windows Features**
   - Enable WSL2: 
     ```powershell
     wsl --install -d Ubuntu-22.04
     ```
   - Enable Virtual Machine Platform:
     ```powershell
     dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
     ```
   - Enable Windows Subsystem for Linux:
     ```powershell
     dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
     ```
   - Restart your computer after enabling these features

2. **Install Docker Desktop**
   - Download from [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Enable WSL2 integration in Docker Desktop settings
   - Allocate at least 6GB memory to Docker

3. **Install Required Software**
   - [VS Code](https://code.visualstudio.com/)
   - [Windows Terminal](https://aka.ms/terminal)
   - [Git for Windows](https://git-scm.com/download/win)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
   - [Helm](https://helm.sh/docs/intro/install/)
   - [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

## 🐧 WSL2 Ubuntu Setup

1. Launch Ubuntu from the Start menu and complete initial setup
2. Update packages:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
3. Install essential tools:
   ```bash
   sudo apt install -y build-essential curl wget git unzip jq
   ```
4. Install MicroK8s:
   ```bash
   sudo snap install microk8s --classic --channel=1.28/stable
   sudo usermod -a -G microk8s $USER
   newgrp microk8s
   ```
5. Configure kubectl alias:
   ```bash
   echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
   echo "alias k='microk8s kubectl'" >> ~/.bashrc
   source ~/.bashrc
   ```
6. Enable required MicroK8s addons:
   ```bash
   microk8s enable dns storage ingress metrics-server registry
   ```

## ☸️ Kubernetes Cluster Setup

1. **Verify MicroK8s Status**
   ```bash
   microk8s status --wait-ready
   ```

2. **Configure kubectl**
   ```bash
   mkdir -p ~/.kube
   microk8s config > ~/.kube/config
   export KUBECONFIG=~/.kube/config
   echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Install ArgoCD**
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   
   # Wait for all pods to be ready
   kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
   
   # Get initial admin password
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   
   # Port-forward ArgoCD UI
   kubectl port-forward svc/argocd-server -n argocd 8080:80 &
   ```
   Access ArgoCD at: http://localhost:8080

## 🚀 Application Deployment

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/TasklistApp.git
   cd TasklistApp
   ```

2. **Create Namespaces**
   ```bash
   kubectl create namespace tasklistapp
   kubectl create namespace monitoring
   ```

3. **Deploy Database**
   ```bash
   kubectl apply -f k8s/postgres/
   ```

4. **Deploy Application**
   ```bash
   kubectl apply -f k8s/backend/
   kubectl apply -f k8s/frontend/
   kubectl apply -f k8s/ingress/
   ```

5. **Verify Deployment**
   ```bash
   kubectl get all -n tasklistapp
   kubectl get ingress -n tasklistapp
   ```

## 🔄 CI/CD Pipeline Setup

1. **GitHub Actions**
   - Create a new GitHub repository
   - Push the code to the repository
   - Add the following secrets in GitHub repository settings:
     - `DOCKERHUB_USERNAME`: Your Docker Hub username
     - `DOCKERHUB_TOKEN`: Your Docker Hub access token
     - `KUBECONFIG`: Your kubeconfig file content

2. **ArgoCD Application**
   ```bash
   kubectl apply -f k8s/argocd/app-of-apps.yaml -n argocd
   ```

3. **Access Applications**
   - Frontend: http://tasklistapp.local
   - Backend API: http://api.tasklistapp.local
   - ArgoCD: http://localhost:8080

## 🛠️ Local Development Setup

### Hosts File Configuration

For local development, add these entries to your `/etc/hosts` file (Windows: `C:\Windows\System32\drivers\etc\hosts`):

```
127.0.0.1    tasklistapp.local
127.0.0.1    api.tasklistapp.local
127.0.0.1    argocd.tasklistapp.local
```

On Windows, you'll need to edit the hosts file as Administrator. On WSL/Ubuntu, use:

```bash
sudo nano /etc/hosts
```

### Backend Development

1. **Prerequisites**
   - Java 17
   - Maven
   - Docker (for database)

2. **Start Development Database**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d postgres
   ```

3. **Run Backend**
   ```bash
   cd backend
   mvn spring-boot:run -Dspring-boot.run.profiles=dev
   ```

### Frontend Development

1. **Prerequisites**
   - Node.js 16+
   - npm or yarn

2. **Install Dependencies**
   ```bash
   cd frontend
   npm install
   ```

3. **Start Development Server**
   ```bash
   REACT_APP_API_URL=http://localhost:8080/api npm start
   ```

## 📚 Useful Commands

```bash
# Get pods
kubectl get pods -A

# View logs
kubectl logs -f <pod-name> -n <namespace>

# Port-forward services
kubectl port-forward svc/<service-name> -n <namespace> <local-port>:<service-port>

# Access Kubernetes dashboard
microk8s dashboard-proxy

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🧹 Cleanup

To remove everything:

```bash
# Delete application
kubectl delete -f k8s/ --recursive

# Uninstall ArgoCD
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd

# Reset MicroK8s (WARNING: This will delete all data)
microk8s reset
```

## 📝 Troubleshooting

### Common Issues

1. **MicroK8s not starting**
   ```bash
   sudo snap restart microk8s
   microk8s inspect
   ```

2. **Docker not working in WSL2**
   - Make sure Docker Desktop is running with WSL2 integration enabled
   - Restart Docker Desktop

3. **ArgoCD pods in CrashLoopBackOff**
   ```bash
   kubectl logs -n argocd <pod-name> --previous
   kubectl describe pod -n argocd <pod-name>
   ```

4. **Insufficient resources**
   - Increase WSL2 memory limit in `%UserProfile%\.wslconfig`:
     ```
     [wsl2]
     memory=8GB
     processors=4
     ```
   - Restart WSL: `wsl --shutdown`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 1. Start the Database

```bash
# Navigate to the project root
cd TasklistApp

# Start PostgreSQL with Docker
docker-compose -f docker-compose.dev.yml up -d
```

### 2. Build and Run the Backend

```bash
# Navigate to the backend directory
cd backend

# Build the application
mvn clean install

# Run the Spring Boot application
mvn spring-boot:run
```

The backend will be available at `http://localhost:8080`

## 🖥️ Frontend Setup

### 1. Install Dependencies

```bash
# Navigate to the frontend directory
cd frontend

# Install dependencies
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the frontend directory:

```env
REACT_APP_API_URL=http://localhost:8080/api
```

### 3. Start the Development Server

```bash
# Start the development server
npm start
```

The frontend will be available at `http://localhost:3000`

## 🐳 Docker Setup (Alternative)

If you prefer to run everything with Docker:

```bash
# From the project root
docker-compose -f docker-compose.dev.yml up --build
```

This will start:
- PostgreSQL database
- Spring Boot backend
- React frontend

## 🌐 Access the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Database: PostgreSQL on port 5432
  - Username: postgres
  - Password: postgres
  - Database: tasklistdb

## 🧪 Running Tests

### Backend Tests

```bash
cd backend
mvn test
```

### Frontend Tests

```bash
cd frontend
npm test
```

## 🔧 Development Scripts

### Frontend

- `npm start` - Start development server
- `npm test` - Run tests
- `npm run build` - Create production build
- `npm run eject` - Eject from Create React App (irreversible)

### Backend

- `mvn spring-boot:run` - Start the Spring Boot application
- `mvn test` - Run tests
- `mvn package` - Create a JAR file

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
