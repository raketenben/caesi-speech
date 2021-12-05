FROM node:14.18.2-stretch
RUN apt-get update
RUN apt-get install build-essential
RUN apt-get install libstdc++6
RUN apt-get install -y gcc-7 g++-7 cpp-7
WORKDIR /usr/app
COPY ./src/ src/
COPY ./public/ public/
COPY ./server.js server.js
COPY ./package.json package.json
COPY ./package-lock.json package-lock.json
COPY ./babel.config.js babel.config.js
RUN npm ci
RUN npm run build
VOLUME [ "/models" ]
CMD [ "nodejs", "server.js" ]
EXPOSE 8080