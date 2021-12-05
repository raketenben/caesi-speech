FROM node:14.18.2-stretch
RUN apt-get install aptitude
RUN aptitude install build-essential
RUN aptitude install libstdc++6
RUN aptitude install -y gcc-7 g++-7 cpp-7
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