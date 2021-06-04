# ![][sgroup-logo] Docker Seminar


## 📌 Requirement

Các bạn vui lòng cài đặt trước môi trường:

- NodeJs
- MySQL
- MySQL Workbench (optional)
- Docker
- Json Formatter Chrome Extension (optional)


## 📌 Guide

1. Mọi  nguời tiến hành tạo database theo như đoạn script có sẵn trong `migrations/migration.sql`

2. Sau đó chạy các command sau

```sh
$ git clone <url-repo>

$ git checkout vy-starter

$ cd seminar-docker-sgroup/

$ npm i express mysql

# DB_HOST=<your-db-host> DB_USER=<your-db-user> DB_PASSWORD=<your-db-user-password> DB_NAME=<your-db-name> node app

$ DB_HOST=localhost DB_USER=root DB_PASSWORD=123123 DB_NAME=seminar_sgroup node app
```



[sgroup-logo]: https://res.cloudinary.com/dgext7ewd/image/upload/v1622822649/github-profile/small-sgroup-logo_p0xwbb.png