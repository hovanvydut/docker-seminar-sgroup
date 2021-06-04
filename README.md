# ![][sgroup-logo] Docker Seminar


## 📌 Requirement

Các bạn vui lòng cài đặt trước môi trường:

- NodeJs
- MySQL
- MySQL Workbench (optional)
- Docker
- Json Formatter Chrome Extension (optional)


## 📌 Guide  

&nbsp;

### 📎 Phase 1: Run app without Docker

&nbsp;

1. Mọi  nguời tiến hành tạo database theo như đoạn script có sẵn trong `migrations/migration.sql`

2. Sau đó chạy các command sau

```sh
git clone <url-repo>

git checkout vy-starter

cd seminar-docker-sgroup/

npm i express mysql

# DB_HOST=<your-db-host> DB_USER=<your-db-user> DB_PASSWORD=<your-db-user-password> DB_NAME=<your-db-name> node app

DB_HOST=localhost DB_USER=root DB_PASSWORD=123123 DB_NAME=seminar_sgroup node app
```

3. Mở trình duyệt lên tai địa chỉ http://localhost:3000/ để xem kết quả

&nbsp;

### 📎 Phase 2: Run app with Docker (using MySQL image)

&nbsp;

**Step 2.1**
1. Chạy đoạn script sau ở MySQL Workbench (hoặc dùng MySql CLI, ...):\
`drop database seminar_sgroup;`
2. Chạy lại app: 
```sh
DB_HOST=localhost DB_USER=root DB_PASSWORD=123123 DB_NAME=seminar_sgroup node app
```
Và mở trình duyệt lên tại địa chỉ http://localhost:3000/ thì mọi người xem log server sẽ thấy lỗi, đó là tại vì MySQL của mình đã xóa `seminar_sgroup` database.

**Step 2.2 Tích hơp docker vào project**
1. Khởi động docker: \
Window: dùng Docker Client\
Ubuntu:
    * chạy docker:  
    ```sh
    sudo systemctl start docker
    ```
    * kiểm tra docker chạy chưa: 
    ```sh
    sudo systemctl status docker
    ```
2. Pull image MySQL từ docker registry về
    ```sh
    docker pull docker.io/library/mysql:8.0.25
    # or shortcut
    docker pull mysql:8.0.25
    ``` 
    Liệt kê các images đã pull
    ```sh
    docker images
    # or
    docker image ls
    ```
3. Chạy docker MySQL image
    Để có thể chạy được MySQL image, mọi người phải thiết lập một số biên môi trường khi chạy container (xem thêm tại [MySQL Docker hub](https://hub.docker.com/_/mysql)):

    * MYSQL_ROOT_PASSWORD: This variable is mandatory and specifies the password that will be set for the MySQL root superuser account. (trích từ [MySQL Docker hub](https://hub.docker.com/_/mysql))

    * Nơi lưu trữ dữ liệu của mysql là ở thư mực `/var/lib/mysql`

    * Để tự động tạo table `seminar_sgroup` cũng như insert data vào table khi container mysql được chạy thì phải tiến hành map volume thư mục `/migrations` của project trên máy bạn với thư mục `/docker-entrypoint-initdb.d` bên trong mysql contaner (tham khảo thêm mục **Initializing a fresh instance** trong [MySQL Docker hub](https://hub.docker.com/_/mysql))

    * Giả sử thư mục hiện tại của project mình hiện là `/home/hovanvydut/Documents/coding/docker/semina-docker-sgroup`
    Sau đó mình sẽ thực hiện lệnh sau để thiết lập biến môi trường

    * mysql 8 uses caching_sha2_password as the default authentication plugin instead of mysql_native_password. If you're having problems with it, you can change to the old authentication plugin (trích từ [mysql docs](https://dev.mysql.com/doc/refman/8.0/en/caching-sha2-pluggable-authentication.html))

    ```
    MYPROJECT=/home/hovanvydut/Documents/coding/docker/semina-docker-sgroup
    ```

    Và giờ ta sẽ chạy lệnh docker sau:
    ```sh
    docker container run -d -p 3307:3306 -v ${MYPROJECT}/migrations:/docker-entrypoint-initdb.d -v ${MYPROJECT}/storage:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=321321 --name mysql-container mysql:8.0.25 mysqld --default-authentication-plugin=mysql_native_password
    ```
    Lệnh trên sẽ mapping port 3306 của container với port 3307 của máy chúng ta, cũng như mount thư mục `/docker-entrypoint-initdb.d` bên trong container với thư mục `${MYPROJECT}/migrations`, và mount thư mục `/var/lib/mysql` bên trong container với thư mục `${MYPROJECT}/storage` bên ngoài của chúng ta

    Sau đó chạy lệnh sau để khởi động app:
    ```sh
    DB_HOST=localhost DB_USER=root DB_PASSWORD=321321 DB_NAME=seminar_sgroup DB_PORT=3307 node app
    ```
    Check app tại: http://localhost:3000/
    Check thư mục `${MYPROJECT}/storage` sẽ thấy toàn bộ dữ liệu của mysql đã được mount với thư mục trên máy tính của ta

**Step 3 Sử dụng docker-compose**
1. Tạo 2 file lần lượt là `Dockerfile` (lưu ý file này không có phần đuôi - extension), `.dockerignore` (lưu ý bao gồm cả dấu chấm phía trước).
2. Thêm vào file `.dockerignore` nội dung sau
```
node_modules
```

[sgroup-logo]: https://res.cloudinary.com/dgext7ewd/image/upload/v1622822649/github-profile/small-sgroup-logo_p0xwbb.png

docker ps
docke  exec -it 8992
