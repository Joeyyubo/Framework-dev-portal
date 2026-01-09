#!/bin/bash

# 准备 Kubernetes manifests，替换模板变量
# 使用方法: ./prepare-manifests.sh <app-name>
# 例如: ./prepare-manifests.sh my-rhdh-portal

set -e

if [ -z "$1" ]; then
    echo "❌ 错误: 请提供应用名称"
    echo "使用方法: $0 <app-name>"
    echo "例如: $0 my-rhdh-portal"
    exit 1
fi

APP_NAME="$1"
APP_NAME_CLEAN=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

echo "=== 准备 Kubernetes Manifests ==="
echo "应用名称: $APP_NAME_CLEAN"
echo ""

# 备份原始文件（如果存在）
if [ -d "backup" ]; then
    rm -rf backup
fi
mkdir -p backup
cp *.yaml backup/ 2>/dev/null || true

# 替换所有文件中的模板变量
for file in *.yaml; do
    if [ -f "$file" ]; then
        echo "处理: $file"
        sed -i.bak "s/{{ values.portalName }}/$APP_NAME_CLEAN/g" "$file"
        rm -f "$file.bak"
    fi
done

# 处理 deploy.sh
if [ -f "deploy.sh" ]; then
    echo "处理: deploy.sh"
    sed -i.bak "s/{{ values.portalName }}/$APP_NAME_CLEAN/g" "deploy.sh"
    rm -f "deploy.sh.bak"
fi

echo ""
echo "=== ✅ 完成 ==="
echo ""
echo "所有模板变量已替换为: $APP_NAME_CLEAN"
echo ""
echo "现在可以运行: ./deploy.sh"


