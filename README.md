# ![][sgroup-logo] Docker Seminar


## 📌 Requirement

Các bạn vui lòng cài đặt trước môi trường:

- NodeJs
- MySQL
- MySQL Workbench (optional)
- Docker
- Json Formatter Chrome Extension or cURL (optional)


## 📌 Guide  

> Tổng quan: chúng ta sẽ cùng nhau build một ứng dụng trong đó có sử dụng nodejs để làm server load tất cả dữ liệu trong MySql database ra.

Ứng dụng sẽ thực hiện qua nhiều giai đoạn:
1. Xây dựng ứng dụng NodeJs + MySql
2. Đóng gói MySql thành 1 container, rồi dùng app nodejs connect tới mysql container
3. Cotainerized app nodejs, sau đó connect với mysql container đã build ở giai đoạn 2 thông qua network
4. Từ những gì đạt được ở giai đoạn 3, tiến hành viết docker-compose cho toàn bộ ứng dụng nodejs + mysql

&nbsp;

### 📎 Phase 1: Run app without Docker

&nbsp;

Trước tiên mọi nguời cần clone repo demo về
```sh
# ssh
git clone -b init-lab-02 git@github.com:dangphu2412/simple-docker.git
# or use https
git clone -b https://github.com/dangphu2412/simple-docker.git
```

1. Sử dụng MySql Workbench hoặc mysql client để chạy đoạn script -> `migrations/migration.sql`

2. Sau đó chạy các command sau

```sh

cd simple-docker/

npm i

# DB_HOST=<your-db-host> DB_USER=<your-db-user> DB_PASSWORD=<your-db-user-password> DB_NAME=<your-db-name> node app

DB_HOST=localhost DB_USER=root DB_PASSWORD=123123 DB_NAME=seminar_sgroup node app
```

3. Mở trình duyệt lên tai địa chỉ http://localhost:3000/ để xem kết quả


[sgroup-logo]: https://res.cloudinary.com/dgext7ewd/image/upload/v1622822649/github-profile/small-sgroup-logo_p0xwbb.png


