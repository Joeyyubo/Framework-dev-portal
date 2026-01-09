# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Enable corepack for Yarn 3.8.7
RUN corepack enable

# Copy package files
COPY package.json yarn.lock* .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# Install dependencies
RUN yarn install --immutable

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Production stage
FROM node:22-alpine AS runner

WORKDIR /app

# Enable corepack in runner
RUN corepack enable

# Copy package files for runtime
COPY package.json yarn.lock* .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# Install dependencies (Yarn 3 uses --immutable instead of --production)
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
# URL will be injected via Railway environment variables
ENV APP_CONFIG_app_baseUrl=${APP_CONFIG_app_baseUrl}

# Start the backend - Explicitly pointing to the index file to avoid MODULE_NOT_FOUND
CMD ["node", "packages/backend/dist/index.cjs.js"]