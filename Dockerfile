FROM node:bullseye
LABEL maintainer="bendik@arbogast.dev"

RUN apt update && apt install dos2unix

WORKDIR /app
COPY . .

# install global dependencies
RUN npm install -g esbuild typescript
# install local dependencies
RUN npm install
# subproject
WORKDIR /app/src/loader
RUN npm install

WORKDIR /app
# build the project
RUN dos2unix ./build-script
RUN bash ./build-script
# webserver
EXPOSE 3000

ENTRYPOINT [ "node", "index.js" ]
