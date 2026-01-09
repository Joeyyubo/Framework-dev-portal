# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# 1. 启用 Corepack 以支持 Yarn 3.8.7
RUN corepack enable

# 2. 复制 Yarn 配置文件和依赖定义
COPY package.json yarn.lock* .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# 3. 安装所有依赖
RUN yarn install --immutable

# 4. 复制源代码并执行构建
COPY . .
RUN yarn build

# Production stage
FROM node:22-alpine AS runner

WORKDIR /app

# 5. 再次启用 Corepack
RUN corepack enable

# 6. 完整复制构建产物，确保路径链接完整
COPY --from=builder /app ./

# 7. 设置生产环境变量
ENV NODE_ENV=production

# 这里的 URL 会通过 Railway 的 Variables 注入
ENV APP_CONFIG_app_baseUrl=${APP_CONFIG_app_baseUrl}

# 8. 暴露端口
EXPOSE 7007

# 9. 使用 yarn workspace 启动，它会自动寻找正确的入口文件
# 这种方式比直接 node 指定路径更可靠，能自动处理依赖映射
CMD ["yarn", "workspace", "backend", "start"]