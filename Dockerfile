FROM node:latest
LABEL maintainer="bendik@arbogast.dev"
WORKDIR /app
# Copy package.json and package-lock.json.
COPY package* ./
# Copy the rest of the application code.
COPY . .
# Web server.
EXPOSE 3000
# Install dependencies.
RUN npm install
# Install sqlite3.
RUN npm install esbuild
# Install pm2 globally.
RUN npm install typescript
# Build the project.
RUN ./build-script
# Start the app.
CMD [ "node", "index.js" ]
