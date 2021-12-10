FROM node:15.14.0-buster
RUN apt-get update
RUN apt-get install build-essential
RUN apt-get install libstdc++6
RUN export LD_LIBRARY_PATH="/usr/local/lib64/:$LD_LIBRARY_PATH"
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