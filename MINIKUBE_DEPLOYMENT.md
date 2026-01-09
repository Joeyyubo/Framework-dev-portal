# 部署 RHDH 实例到 Minikube

本指南说明如何将 RHDH 实例部署到本地 minikube 集群。

## 📋 前置要求

1. **安装 minikube**
   ```bash
   # macOS
   brew install minikube
   
   # 或使用其他方式安装
   # https://minikube.sigs.k8s.io/docs/start/
   ```

2. **安装 kubectl**
   ```bash
   # macOS
   brew install kubectl
   ```

3. **安装 Docker**
   - macOS: 安装 Docker Desktop
   - Linux: 安装 Docker Engine

## 🚀 快速部署

### 方法 1: 使用部署脚本（推荐）

```bash
# 1. 进入项目目录
cd your-rhdh-instance

# 2. 进入 minikube manifests 目录
cd manifests/minikube

# 3. 准备 manifests（替换模板变量）
chmod +x prepare-manifests.sh
./prepare-manifests.sh your-app-name

# 4. 运行部署脚本
./deploy.sh
```

**注意：** `prepare-manifests.sh` 会自动将所有 `{{ values.portalName }}` 替换为你提供的应用名称。

### 方法 2: 手动部署

#### 步骤 1: 启动 minikube

```bash
# 启动 minikube
minikube start

# 检查状态
minikube status
```

#### 步骤 2: 配置 Docker 环境

```bash
# 配置 Docker 使用 minikube 的 Docker daemon
eval $(minikube docker-env)

# 验证
docker ps
```

#### 步骤 3: 构建 Docker 镜像

```bash
# 在项目根目录
docker build -t your-app-rhdh:latest .
```

#### 步骤 4: 应用 Kubernetes 配置

```bash
# 进入 manifests/minikube 目录
cd manifests/minikube

# 应用所有配置
kubectl apply -f .
```

#### 步骤 5: 等待部署完成

```bash
# 查看部署状态
kubectl get deployments

# 查看 Pod 状态
kubectl get pods

# 等待 Pod 就绪
kubectl wait --for=condition=ready pod -l app=your-app-rhdh --timeout=300s
```

## 🌐 访问应用

### 方式 1: 使用 NodePort（最简单）

```bash
# 使用 minikube service 命令（会自动打开浏览器）
minikube service your-app-rhdh

# 或获取 URL
minikube service your-app-rhdh --url
```

访问地址通常是：`http://<minikube-ip>:30007`

### 方式 2: 使用 Ingress（推荐用于开发）

#### 启用 Ingress 插件

```bash
# 启用 nginx ingress 控制器
minikube addons enable ingress

# 检查 ingress 状态
kubectl get pods -n ingress-nginx
```

#### 配置 hosts 文件

```bash
# 获取 minikube IP
MINIKUBE_IP=$(minikube ip)

# 添加到 /etc/hosts（需要 sudo）
echo "$MINIKUBE_IP your-app-rhdh.local" | sudo tee -a /etc/hosts
```

#### 访问应用

```bash
# 在浏览器中访问
http://your-app-rhdh.local
```

### 方式 3: 使用端口转发

```bash
# 端口转发
kubectl port-forward service/your-app-rhdh 7007:7007

# 在浏览器中访问
http://localhost:7007
```

## 📝 配置说明

### 更新 ConfigMap

如果需要修改配置：

```bash
# 编辑 ConfigMap
kubectl edit configmap your-app-rhdh-config

# 或重新应用
kubectl apply -f manifests/minikube/configmap.yaml

# 重启 Pod 使配置生效
kubectl rollout restart deployment/your-app-rhdh
```

### 环境变量

可以通过修改 `deployment.yaml` 中的环境变量来配置：

```yaml
env:
- name: APP_CONFIG_app_baseUrl
  value: "http://your-app-rhdh.local"
- name: APP_CONFIG_backend_baseUrl
  value: "http://your-app-rhdh.local"
```

## 🔍 查看日志和调试

### 查看 Pod 日志

```bash
# 查看所有 Pod
kubectl get pods

# 查看特定 Pod 的日志
kubectl logs -f deployment/your-app-rhdh

# 查看最近的日志
kubectl logs --tail=100 deployment/your-app-rhdh
```

### 进入 Pod 调试

```bash
# 获取 Pod 名称
POD_NAME=$(kubectl get pods -l app=your-app-rhdh -o jsonpath='{.items[0].metadata.name}')

# 进入 Pod
kubectl exec -it $POD_NAME -- /bin/sh
```

### 查看资源状态

```bash
# 查看所有资源
kubectl get all -l app=your-app-rhdh

# 查看详细信息
kubectl describe deployment/your-app-rhdh
kubectl describe service/your-app-rhdh
kubectl describe ingress/your-app-rhdh
```

## 🗄️ 数据库

### 使用 SQLite（默认）

配置使用 SQLite，数据存储在 PersistentVolumeClaim 中：

```yaml
database:
  client: better-sqlite3
  connection:
    directory: /app/database
```

数据会持久化在 PVC 中，即使 Pod 重启也不会丢失。

### 使用 PostgreSQL（可选）

如果需要使用 PostgreSQL：

1. **部署 PostgreSQL**

```bash
# 使用 Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgresql bitnami/postgresql

# 获取密码
kubectl get secret postgresql -o jsonpath='{.data.postgres-password}' | base64 -d
```

2. **更新 ConfigMap**

```yaml
database:
  client: pg
  connection:
    host: postgresql.default.svc.cluster.local
    port: 5432
    user: postgres
    password: <password>
    database: backstage
```

## 🧹 清理资源

### 删除部署

```bash
# 删除所有资源
kubectl delete -f manifests/minikube/

# 或删除特定资源
kubectl delete deployment/your-app-rhdh
kubectl delete service/your-app-rhdh
kubectl delete ingress/your-app-rhdh
kubectl delete configmap/your-app-rhdh-config
kubectl delete pvc/your-app-rhdh-database
```

### 停止 minikube

```bash
# 停止 minikube（保留数据）
minikube stop

# 删除 minikube 集群（删除所有数据）
minikube delete
```

## 🚨 常见问题

### 1. Pod 无法启动

**检查：**
```bash
# 查看 Pod 状态
kubectl get pods

# 查看 Pod 详细信息
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name>
```

**常见原因：**
- 镜像构建失败
- 配置错误
- 资源不足

### 2. 无法访问应用

**检查：**
```bash
# 检查 Service
kubectl get svc

# 检查 Ingress
kubectl get ingress

# 检查 Pod 是否就绪
kubectl get pods -l app=your-app-rhdh
```

### 3. 数据库连接失败

**解决：**
- 检查 PVC 是否正确创建
- 检查数据库配置路径
- 查看 Pod 日志

### 4. 镜像拉取失败

**解决：**
```bash
# 确保使用 minikube 的 Docker 环境
eval $(minikube docker-env)

# 重新构建镜像
docker build -t your-app-rhdh:latest .
```

## 📚 更多资源

- [Minikube 文档](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes 文档](https://kubernetes.io/docs/)
- [Backstage 部署指南](https://backstage.io/docs/deployment)

## 💡 提示

1. **开发环境**：使用 `kubectl port-forward` 最简单
2. **测试环境**：使用 Ingress + hosts 文件
3. **生产环境**：考虑使用完整的 Kubernetes 集群（如 GKE, EKS, AKS）

---

**需要帮助？** 查看日志或检查资源状态，大多数问题都可以通过日志解决！

