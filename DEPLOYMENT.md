# 部署 RHDH 实例指南

这个文档说明如何将 RHDH 实例部署到各种平台，使其可以通过公共 URL 访问（类似 GitHub Pages）。

## 🚀 快速部署选项

### 选项 1: Railway（推荐 - 最简单）

Railway 是一个全栈应用部署平台，支持自动部署。

#### 步骤：

1. **注册 Railway 账号**
   - 访问 https://railway.app
   - 使用 GitHub 账号登录

2. **创建新项目**
   - 点击 "New Project"
   - 选择 "Deploy from GitHub repo"
   - 选择你的 RHDH 仓库

3. **配置环境变量**
   - 在 Railway 项目设置中添加：
     - `NODE_ENV=production`
     - `APP_CONFIG_app_baseUrl=https://your-app.railway.app`（Railway 会自动提供）

4. **部署**
   - Railway 会自动检测 `Dockerfile` 并开始构建
   - 等待部署完成（约 5-10 分钟）

5. **访问**
   - Railway 会提供一个公共 URL，例如：`https://your-app.railway.app`

#### 优点：
- ✅ 完全免费（有限制）
- ✅ 自动 HTTPS
- ✅ 自动部署（Git push 触发）
- ✅ 简单易用

---

### 选项 2: Render

Render 是另一个优秀的全栈应用部署平台。

#### 步骤：

1. **注册 Render 账号**
   - 访问 https://render.com
   - 使用 GitHub 账号登录

2. **创建新 Web Service**
   - 点击 "New +" → "Web Service"
   - 连接你的 GitHub 仓库

3. **配置部署**
   - **Build Command**: `yarn install && yarn build`
   - **Start Command**: `node packages/backend`
   - **Environment**: `Docker`

4. **配置环境变量**
   - 添加环境变量：
     - `NODE_ENV=production`
     - `APP_CONFIG_app_baseUrl=https://your-app.onrender.com`

5. **部署**
   - 点击 "Create Web Service"
   - 等待部署完成

#### 优点：
- ✅ 免费套餐可用
- ✅ 自动 HTTPS
- ✅ 简单配置

---

### 选项 3: Fly.io

Fly.io 支持全球部署，性能优秀。

#### 步骤：

1. **安装 Fly CLI**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **登录 Fly.io**
   ```bash
   fly auth login
   ```

3. **初始化 Fly 应用**
   ```bash
   fly launch
   ```

4. **部署**
   ```bash
   fly deploy
   ```

#### 优点：
- ✅ 全球 CDN
- ✅ 高性能
- ✅ 免费套餐可用

---

### 选项 4: Docker + 云平台

如果你有自己的云服务器或 Kubernetes 集群。

#### 步骤：

1. **构建 Docker 镜像**
   ```bash
   docker build -t your-app-rhdh .
   ```

2. **运行容器**
   ```bash
   docker run -d -p 7007:7007 \
     -e NODE_ENV=production \
     -e APP_CONFIG_app_baseUrl=https://your-domain.com \
     your-app-rhdh
   ```

3. **配置反向代理（Nginx）**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:7007;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

4. **配置 HTTPS（Let's Encrypt）**
   ```bash
   certbot --nginx -d your-domain.com
   ```

---

## 📝 重要配置

### 更新 app-config.yaml

部署前，需要更新 `app-config.yaml` 中的 URL：

```yaml
app:
  baseUrl: https://your-app.railway.app  # 替换为你的实际 URL

backend:
  baseUrl: https://your-app.railway.app  # 替换为你的实际 URL
  cors:
    origin: https://your-app.railway.app  # 替换为你的实际 URL
```

### 环境变量

在生产环境中，建议使用环境变量：

```bash
APP_CONFIG_app_baseUrl=https://your-app.railway.app
APP_CONFIG_backend_baseUrl=https://your-app.railway.app
```

---

## 🔧 数据库配置

### 开发环境（默认）
- 使用 SQLite（文件数据库）
- 数据存储在 `backstage.db`

### 生产环境（推荐）
- 使用 PostgreSQL
- 在 `app-config.yaml` 中配置：

```yaml
backend:
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DATABASE}
```

大多数部署平台（Railway, Render）都提供 PostgreSQL 插件，可以自动配置。

---

## 🚨 常见问题

### 1. 部署后无法访问

**检查：**
- ✅ 环境变量 `APP_CONFIG_app_baseUrl` 是否正确
- ✅ 端口是否正确暴露（7007）
- ✅ 防火墙规则是否允许访问

### 2. 前端无法连接后端

**解决：**
- 确保 `backend.baseUrl` 和 `app.baseUrl` 都指向正确的 URL
- 检查 CORS 配置

### 3. 数据库连接失败

**解决：**
- 检查数据库连接字符串
- 确保数据库服务正在运行
- 检查网络连接

---

## 📚 更多资源

- [Railway 文档](https://docs.railway.app)
- [Render 文档](https://render.com/docs)
- [Fly.io 文档](https://fly.io/docs)
- [Backstage 部署指南](https://backstage.io/docs/deployment)

---

## 💡 推荐方案

对于快速部署，**推荐使用 Railway**：
- ✅ 最简单
- ✅ 免费套餐足够使用
- ✅ 自动 HTTPS
- ✅ 自动部署

只需：
1. 推送代码到 GitHub
2. 在 Railway 中连接仓库
3. 等待自动部署
4. 获得公共 URL！


