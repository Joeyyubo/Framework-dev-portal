#!/bin/bash

# 部署 RHDH 实例到 minikube 集群
# 使用方法: ./deploy.sh

set -e

APP_NAME="{{ values.portalName }}-rhdh"
NAMESPACE="default"

echo "=== 部署 RHDH 实例到 minikube ==="
echo "应用名称: $APP_NAME"
echo ""

# 检查 minikube 是否运行
if ! minikube status > /dev/null 2>&1; then
    echo "❌ minikube 未运行，正在启动..."
    minikube start
fi

echo "✅ minikube 正在运行"
echo ""

# 检查 Docker 环境（minikube 使用）
echo "📦 配置 Docker 环境..."
eval $(minikube docker-env)
echo "✅ Docker 环境已配置"
echo ""

# 构建 Docker 镜像
echo "🔨 构建 Docker 镜像..."
docker build -t $APP_NAME:latest .
echo "✅ Docker 镜像构建完成"
echo ""

# 应用 Kubernetes 配置
echo "🚀 部署到 Kubernetes..."
kubectl apply -f .

# 等待部署就绪
echo "⏳ 等待部署就绪..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME || true

echo ""
echo "=== ✅ 部署完成 ==="
echo ""
echo "访问方式："
echo ""
echo "1. 使用 NodePort（推荐）:"
echo "   minikube service $APP_NAME"
echo ""
echo "2. 使用 Ingress（需要启用 ingress 插件）:"
echo "   minikube addons enable ingress"
echo "   然后访问: http://{{ values.portalName }}.local"
echo "   （需要在 /etc/hosts 中添加: $(minikube ip) {{ values.portalName }}.local）"
echo ""
echo "3. 使用端口转发:"
echo "   kubectl port-forward service/$APP_NAME 7007:7007"
echo "   然后访问: http://localhost:7007"
echo ""
echo "查看日志:"
echo "   kubectl logs -f deployment/$APP_NAME"
echo ""


