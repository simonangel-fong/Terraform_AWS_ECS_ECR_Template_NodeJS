# Use Node.js LTS version as base image
FROM node:20-alpine

# Set working directory
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
