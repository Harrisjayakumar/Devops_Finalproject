# Build stage
FROM node:16-alpine AS build

WORKDIR /app

# Only copy what's necessary for installing deps
COPY package*.json ./

# Install dependencies
RUN npm ci

# Now copy only source files (skip node_modules, .git, etc.)
COPY public ./public
COPY src ./src

# Copy other necessary files (like env and config)
COPY .env .env
COPY .eslintrc .eslintrc
COPY .babelrc .babelrc
COPY tsconfig.json tsconfig.json
COPY craco.config.js craco.config.js
# Add others as needed

# Build the app
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files from build stage to nginx serve directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
