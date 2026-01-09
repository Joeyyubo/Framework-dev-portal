# 阶段 1: 构建阶段 (Build Stage)
FROM node:22-alpine AS builder

# 1. 核心修复：安装构建 better-sqlite3 等原生模块所需的系统工具
# Alpine 镜像非常精简，必须手动添加这些工具才能完成 yarn build
RUN apk add --no-cache python3 make g++

WORKDIR /app

# 2. 启用 Corepack 以支持 Yarn 3.8.7 
RUN corepack enable

# 3. 复制依赖定义文件
COPY package.json yarn.lock* .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# 4. 安装依赖 (使用 --immutable 确保 Yarn 3 状态一致) 
RUN yarn install --immutable

# 5. 复制全量源代码并执行构建
# 这里的构建会触发 "yarn workspace backend build"
# 成功的构建必须产出 packages/backend/dist/index.cjs.js
COPY . .
RUN yarn build

# 阶段 2: 运行阶段 (Production Stage)
FROM node:22-alpine AS runner

# 运行阶段同样需要基础库来支持原生模块的执行
RUN apk add --no-cache python3 make g++

WORKDIR /app

RUN corepack enable

# 6. 从构建阶段复制所有产物
COPY --from=builder /app ./

# 7. 设置生产环境变量
ENV NODE_ENV=production

# 8. 修改暴露的端口
# Railway 会通过 PORT 环境变量提供端口，这里使用动态端口
# 但 EXPOSE 需要一个具体值，Railway 会自动映射
EXPOSE 7010

# 9. 修正启动命令
# 使用启动脚本来处理 Railway 的 PORT 环境变量
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh
CMD ["/app/start.sh"]