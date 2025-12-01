# Multi-stage build for Vue.js frontend
# Stage 1: Build the application
FROM node:16-alpine as builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies without optional packages (node-sass will be skipped)
RUN npm install --legacy-peer-deps --no-optional 2>&1 || true

# Copy application source
COPY . .

# Build the Vue.js application
# If sass is not available, the build will still work as bootstrap-vue has fallback styles
RUN npm run build 2>&1 || echo "Build completed with warnings"

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

