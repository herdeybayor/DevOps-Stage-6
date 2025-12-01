# Frontend Service - Multi-stage Vue.js build with nginx
FROM node:14-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with legacy peer deps flag for older dependencies
RUN npm install

# Copy application source
COPY . .

# Build the Vue.js application
RUN npm run build

# Production stage - nginx
FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port for nginx
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
