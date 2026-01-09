#!/bin/sh
# Railway 启动脚本
# 确保后端监听正确的端口和地址

# 如果 PORT 环境变量存在（Railway 提供），则使用它
if [ -n "$PORT" ]; then
  export APP_CONFIG_backend_listen_port=$PORT
fi

# 确保监听 0.0.0.0
export APP_CONFIG_backend_listen_host=${APP_CONFIG_backend_listen_host:-0.0.0.0}

# 启动后端 - 使用 yarn workspace 命令，这会调用 backstage-cli package start
# 这会正确处理 tar.gz 包并启动服务
cd /app
exec yarn workspace backend start
