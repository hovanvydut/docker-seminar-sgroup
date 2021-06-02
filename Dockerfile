FROM node:14-alpine

WORKDIR /home/seminar

COPY package*.json ./

RUN npm install

COPY . .

ARG db_host
ARG db_user
ARG db_password
ARG db_name

ENV DB_HOST=$db_host
ENV DB_USER=$db_user
ENV DB_PASSWORD=$db_password
ENV DB_NAME=$db_name

CMD node app