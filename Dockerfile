# --- 阶段 1: 构建阶段 ---
FROM node:22-alpine AS builder

# 1. 安装构建 better-sqlite3 等原生模块所需的系统依赖
# Alpine 镜像默认不含编译工具，必须安装这些才能成功执行 yarn build
RUN apk add --no-cache python3 make g++

WORKDIR /app

# 2. 启用 Corepack 以支持项目使用的 Yarn 版本 
RUN corepack enable

# 3. 复制依赖定义文件
COPY package.json yarn.lock* .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# 4. 安装依赖
RUN yarn install --immutable

# 5. 复制源代码并执行构建
COPY . .
# 这一步会根据 package.json 的定义生成 packages/backend/dist/index.cjs.js 
RUN yarn build

# --- 阶段 2: 运行阶段 ---
FROM node:22-alpine AS runner

# 运行阶段也需要基础构建环境来支持 better-sqlite3
RUN apk add --no-cache python3 make g++

WORKDIR /app

RUN corepack enable

# 6. 从构建阶段复制所有产物
COPY --from=builder /app ./

# 7. 设置环境变量
ENV NODE_ENV=production

# 8. 修改暴露的端口
# 注意：你的 app-config.yaml 中配置的后端端口是 7010
EXPOSE 7010

# 9. 启动命令
# 直接指定入口文件，并显式加载配置文件
# 注意：生产环境通常不建议加载 .local.yaml，只加载基础配置
CMD ["node", "packages/backend/dist/index.cjs.js", "--config", "app-config.yaml"]