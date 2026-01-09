# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json yarn.lock* ./
COPY .yarnrc.yml ./ 
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# 启用 Corepack 并安装所有依赖
RUN corepack enable
RUN yarn install --immutable

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Production stage
FROM node:22-alpine AS runner

WORKDIR /app

# Copy package files
COPY package.json yarn.lock* ./
COPY .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# 再次启用 Corepack 并安装依赖
RUN corepack enable
RUN yarn install --immutable

# Copy built files from builder
COPY --from=builder /app/packages/app/dist ./packages/app/dist
COPY --from=builder /app/packages/backend/dist ./packages/backend/dist

# Copy configuration files
COPY app-config.yaml ./
COPY packages/app/public ./packages/app/public

# Expose port
EXPOSE 7007

# Set environment variables
ENV NODE_ENV=production

# 这里的 URL 建议通过 Railway 的环境变量注入，不要写死
ENV APP_CONFIG_app_baseUrl=${APP_CONFIG_app_baseUrl}

# Start the backend
CMD ["node", "packages/backend"]