FROM node:12

WORKDIR /usr/src/app

COPY ./app ./

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "node", "./app/server.js" ]
