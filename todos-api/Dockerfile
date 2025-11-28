# Dockerfile for Node.js Todos API
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application source
COPY . .

# Expose port 8082
EXPOSE 8082

# Set Node environment to production
ENV NODE_ENV=production

# Run the application
CMD ["node", "server.js"]

