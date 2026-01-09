# Build stage
FROM node:22-alpine AS builder

# 1. 安装构建原生模块 (如 better-sqlite3) 所需的系统依赖
RUN apk add --no-cache python3 make g++

WORKDIR /app

# 2. 启用 Corepack
RUN corepack enable

# 3. 复制 Yarn 配置和依赖定义
COPY package.json yarn.lock* .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# 4. 安装依赖 (使用 --immutable 确保一致性)
RUN yarn install --immutable

# 5. 复制全量源代码
COPY . .

# 6. 执行构建，这一步会生成 packages/backend/dist 目录
RUN yarn build

# Production stage
FROM node:22-alpine AS runner

# 生产环境运行 better-sqlite3 同样需要基础库支持
RUN apk add --no-cache python3 make g++

WORKDIR /app

RUN corepack enable

# 7. 从 builder 阶段复制完整的构建产物
COPY --from=builder /app ./

# 8. 设置生产环境变量
ENV NODE_ENV=production

# 暴露 Backstage 后端默认端口
EXPOSE 7007

# 9. 修正启动命令：
# 直接运行 node 指向报错中提示的入口文件路径
# 同时通过 --config 指定配置文件（Backstage 后端启动通常需要它）
CMD ["node", "packages/backend/dist/index.cjs.js", "--config", "app-config.yaml"]