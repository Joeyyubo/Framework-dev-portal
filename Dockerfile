# --- 阶段 1: 构建阶段 ---
FROM node:22-alpine AS builder

# 安装构建 better-sqlite3 等原生模块所需的系统工具
RUN apk add --no-cache python3 make g++

WORKDIR /app

# 启用 Corepack
RUN corepack enable

# 复制依赖定义（利用 Docker 缓存）
COPY package.json yarn.lock* .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# 安装依赖
RUN yarn install --immutable

# 复制全量源代码
COPY . .

# 执行构建：产出 packages/backend/dist 目录
RUN yarn build

# --- 阶段 2: 运行阶段 ---
FROM node:22-alpine AS runner

# 运行阶段同样需要基础库来支持原生模块
RUN apk add --no-cache python3 make g++

WORKDIR /app

RUN corepack enable

# 从构建阶段复制所有产物
COPY --from=builder /app ./

# 设置生产环境变量
ENV NODE_ENV=production

# 对齐 app-config.yaml 中定义的端口 7010
EXPOSE 7010

# 启动指令：显式指定入口文件并加载配置
CMD ["node", "packages/backend/dist/index.cjs.js", "--config", "app-config.yaml"]