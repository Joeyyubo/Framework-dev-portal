# Railway 部署指南

## 502 Bad Gateway 问题修复

如果你遇到 502 Bad Gateway 错误，请按照以下步骤配置环境变量。

## 必需的环境变量

在 Railway 项目设置中，添加以下环境变量：

### 1. 端口配置（自动处理）

Railway 会自动提供 `PORT` 环境变量。项目中的 `start.sh` 脚本会自动读取 `PORT` 并设置 `APP_CONFIG_backend_listen_port`。

**你不需要手动设置端口相关的环境变量。**

### 2. 监听地址（重要！）

确保后端监听 `0.0.0.0` 而不是 `localhost`：

```
APP_CONFIG_backend_listen_host=0.0.0.0
```

### 3. Base URL 配置

将 `YOUR_RAILWAY_URL` 替换为你的实际 Railway URL（例如：`https://framework-dev-portal-production.up.railway.app`）：

```
APP_CONFIG_app_baseUrl=https://framework-dev-portal-production.up.railway.app
APP_CONFIG_backend_baseUrl=https://framework-dev-portal-production.up.railway.app
```

### 4. CORS 配置

允许你的 Railway 域名：

```
APP_CONFIG_backend_cors_origin=https://framework-dev-portal-production.up.railway.app
```

### 5. 生产环境配置

```
NODE_ENV=production
```

## 完整环境变量列表

在 Railway 项目设置 → Variables 中添加：

```
NODE_ENV=production
APP_CONFIG_backend_listen_host=0.0.0.0
APP_CONFIG_app_baseUrl=https://framework-dev-portal-production.up.railway.app
APP_CONFIG_backend_baseUrl=https://framework-dev-portal-production.up.railway.app
APP_CONFIG_backend_cors_origin=https://framework-dev-portal-production.up.railway.app
```

**注意**：
- 将 `https://framework-dev-portal-production.up.railway.app` 替换为你的实际 Railway URL
- **不需要设置 `APP_CONFIG_backend_listen_port`**：启动脚本会自动从 Railway 的 `PORT` 环境变量读取

## 验证配置

1. 在 Railway 控制台查看部署日志，确认：
   - 后端成功启动
   - 监听在 `0.0.0.0:PORT`（PORT 是 Railway 提供的端口）
   - 没有错误信息

2. 检查健康检查端点：
   - 访问 `https://your-app.railway.app/healthz`
   - 应该返回 200 OK

## 常见问题

### 问题 1: 仍然显示 502

**解决方案**：
- 检查 Railway 日志，查看是否有错误
- 确认 `APP_CONFIG_backend_listen_host=0.0.0.0` 已设置
- 确认 `APP_CONFIG_backend_listen_port=${PORT}` 已设置

### 问题 2: 前端无法加载

**解决方案**：
- 确认 `APP_CONFIG_app_baseUrl` 和 `APP_CONFIG_backend_baseUrl` 都设置为你的 Railway URL
- 确认 `APP_CONFIG_backend_cors_origin` 设置为你的 Railway URL

### 问题 3: 数据库错误

**解决方案**：
- SQLite 文件需要持久化存储
- 考虑使用 Railway 的 PostgreSQL 插件（推荐用于生产环境）

## 使用 PostgreSQL（推荐）

1. 在 Railway 中添加 PostgreSQL 服务
2. 添加环境变量：
   ```
   APP_CONFIG_backend_database_client=pg
   APP_CONFIG_backend_database_connection_host=${PGHOST}
   APP_CONFIG_backend_database_connection_port=${PGPORT}
   APP_CONFIG_backend_database_connection_user=${PGUSER}
   APP_CONFIG_backend_database_connection_password=${PGPASSWORD}
   APP_CONFIG_backend_database_connection_database=${PGDATABASE}
   ```

## 重新部署

配置环境变量后：
1. 在 Railway 控制台点击 "Redeploy"
2. 等待部署完成
3. 检查日志确认没有错误
4. 访问你的应用 URL
