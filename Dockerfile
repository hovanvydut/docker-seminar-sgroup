FROM node:14-alpine

WORKDIR /home/seminar

COPY package*.json ./

RUN npm install

COPY . .

ENV DB_HOST=
ENV DB_USER=
ENV DB_PASSWORD=
ENV DB_NAME=

CMD ["node", "app"]