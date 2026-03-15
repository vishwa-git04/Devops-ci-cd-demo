# ══════════════════════════════════════════
# Stage 1: Build
# ══════════════════════════════════════════
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first (better layer caching)
# If package.json hasn't changed, npm install is cached
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application source code
COPY . .

# Build the application
RUN npm run build

# ══════════════════════════════════════════
# Stage 2: Production Image
# ══════════════════════════════════════════
FROM node:18-alpine AS production

# Set environment
ENV NODE_ENV=production
ENV PORT=3000

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only built files from Stage 1
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Set correct ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 3000

# Health check — Kubernetes uses this to know if pod is healthy
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=15s \
            --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "dist/server.js"]
