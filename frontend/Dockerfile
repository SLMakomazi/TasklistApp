# Build stage
FROM node:18-alpine as build

# Accept build argument
ARG FRONTEND_API_URL

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy project files
COPY . .

# Build the application with provided API URL
ENV REACT_APP_API_URL=$FRONTEND_API_URL
RUN echo "Building with API URL: $REACT_APP_API_URL" && \
    npm run build

# Production stage
FROM nginx:alpine

# Copy built assets from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
