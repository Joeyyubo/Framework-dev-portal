# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json yarn.lock* ./
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Production stage
FROM node:22-alpine AS runner

WORKDIR /app

# Copy package files
COPY package.json yarn.lock* ./
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# Install production dependencies only
RUN yarn install --frozen-lockfile --production

# Copy built files from builder
COPY --from=builder /app/packages/app/dist ./packages/app/dist
COPY --from=builder /app/packages/backend/dist ./packages/backend/dist
COPY --from=builder /app/packages/app/dist-types ./packages/app/dist-types
COPY --from=builder /app/packages/backend/dist-types ./packages/backend/dist-types

# Copy configuration files
COPY app-config.yaml ./
COPY packages/app/public ./packages/app/public

# Expose port
EXPOSE 7007

# Set environment variables
ENV NODE_ENV=production
ENV APP_CONFIG_app_baseUrl=http://localhost:7007

# Start the backend (which serves both frontend and backend)
CMD ["node", "packages/backend"]


