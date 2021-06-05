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
git clone <url-repo>
```

1. Mọi  nguời tiến hành tạo database theo như đoạn script có sẵn trong `migrations/migration.sql`

2. Sau đó chạy các command sau

```sh

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
    > Lệnh trên sẽ mapping port 3306 của container với port 3307 của máy chúng ta, cũng như mount thư mục `/docker-entrypoint-initdb.d` bên trong container với thư mục `${MYPROJECT}/migrations`, và mount thư mục `/var/lib/mysql` bên trong container với thư mục `${MYPROJECT}/storage` bên ngoài của chúng ta.

    Sau đó chạy lệnh sau để khởi động app:
    ```sh
    DB_HOST=localhost DB_USER=root DB_PASSWORD=321321 DB_NAME=seminar_sgroup DB_PORT=3307 node app
    ```
    Check app tại: http://localhost:3000/
    Check thư mục `${MYPROJECT}/storage` sẽ thấy toàn bộ dữ liệu của mysql đã được mount với thư mục trên máy tính của ta

&nbsp;

### 📎 Phase 3: Run app using Nodejs container + MySql container

&nbsp;

Dựa vào 2 phase trước, ta sẽ tiến hành nâng cấp ứng dụng lên. Ở **phase 2** chúng ta mới chỉ containerized mysql thôi, còn nodejs chúng ta vẫn chưa containerized. Ở **phase 3** này chúng ta sẽ tiến hành containerized toàn bộ ứng dụng (nodejs + mysql).

1. **Viết `Dockerfile` cho ứng dụng nodejs**

    Tạo 2 file lần lượt là `Dockerfile` (lưu ý file này không có phần đuôi - extension), `.dockerignore` (lưu ý bao gồm cả dấu chấm phía trước), đặt 2 file cùng cấp với thư mục đặt file `app.js`

    Thêm vào file `.dockerignore` nội dung sau

    ```
    node_modules
    storage
    ```

    Ở `Dockerfile` chúng ta viết như sau:

    ```
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
    ```
    Giải thích:
    * `FROM node:14-alpine` \
    giúp pull nodejs image từ docker hub về

    * `WORKDIR /home/seminar`\
     Set the working directory for any subsequent ADD, COPY, CMD, ENTRYPOINT, or RUN instructions that follow it in the Dockerfile.

    * `COPY package*.json ./` \
    sẽ copy những file có dạng `package*.json` (package.json, package-lock.json) ở cái thư mục mà bạn đặt `Dockerfile` máy bạn vào thư mục `/home/seminar` bên trong container. Nếu xóa câu lệnh `WORKDIR /home/seminar` thì câu lệnh copy của mình phải viết lại như sau `COPY package*.json /home/seminar`

    * Sau khi copy các file `package.json` vào `/home/seminar` trong container, ta tiến hành chạy lệnh `RUN npm install` để install các thư viện cần thiết cho app

    * `COPY . .` \
    sẽ copy toàn bộ những file, folder ở cái thư mục mà bạn đặt `Dockerfile` máy bạn vào folder `/home/seminar` bên trong container.

    * Tiếp theo, sẽ thiết lập các biến môi trường mà app chúng ta cần lúc chạy

    * `CMD ["node", "app"]` sẽ dùng để khởi chạy app khi mà run container

    > Vậy là chúng ta vừa hoàn thành việc viết `Dockerfile` cho phần app nodejs. Việc có `Dockerfile` thì gần như tương đương với việc chúng ta đang sở hữu một cái image với đầy đủ code nodejs cùng config bên trong để sẵn sàng chạy app bất cứ lúc nào.

    Tạo image cho node app từ Dockerfile trên:

    ```sh
    docker image build -t simple-node-app:1.0 .
    ```
    Dùng lệnh `docker images` hoặc `docker image ls` để xem thử có cái image tên là `simple-node-app` với tag là `1.0` chưa?

    Việc còn thiếu bây giờ là chúng ta cần connect cái app của chúng ta với mysql container ở **phase 2**

2. **Connect nodejs container với mysql container thông qua network**

    Tới hiện tại, những gì chúng ta đang có là 1 cái `simple-node-app:1.0` image, 1 cái container `mysql-container`

    Để connect 2 cái container đó, trước tiên ta phải cho cả 2 cái container trên connect cùng một cái network.

    Tạo 1 cái network có tên là `seminar-docker-sgroup-network` với driver là bridge:

    ```sh
    docker network create --driver=bridge seminar-docker-sgroup-network
    ```
    Connect cái network đó tới mysql và gán alias cái ip container network đó là `mysqlHost` :

    ```sh
    docker network connect --alias mysqlHost seminar-docker-sgroup-network <mysql-container-id>
    ```

    > Note: --alias: . The embedded DNS server maintains the mapping between all of the container aliases and its IP address on a specific user-defined network. A container can have different aliases in different networks by using the --alias option in docker network connect command. Readmore: [docs](https://docs.docker.com/engine/reference/commandline/network_connect/)

    Ta sẽ khởi chạy container từ `simple-node-app:1.0` image cũng như connect nó tới cùng `seminar-docker-sgroup-network` network cái mà `mysql-container` cũng đã connect như ở trên

    ```sh
    docker container run -d -e DB_HOST=mysqlHost -e DB_USER=root -e  DB_PASSWORD=321321 -e  DB_NAME=seminar_sgroup -p 3001:3000 --network=seminar-docker-sgroup-network --name seminar-node-app  simple-node-app:1.0
    ```

    Mở trình duyệt lên tại địa chỉ http://localhost:3001/ để xem kết quả

    > Note: Lúc này dùng lệnh `docker container inspect mysql-container` và `docker container inspect seminar-node-app` sẽ thấy thằng `seminar-node-app` nó chỉ có duy nhất 1 network là thằng `seminar-docker-sgroup-network`, trong khi thằng `mysql-container` là có tới 2 cái network là `bridge` và `seminar-docker-sgroup-network`. Đó là bởi vì `mysql-container` ban đầu khởi chạy không có gán network cho nó, nên nó sẽ nhận mặc định một cái `bridge` default network, sau đó chúng ta mới tiến hành connect cái `seminar-docker-sgroup-network` tới cái `mysql-container` đang chạy. (Lưu ý, tại 1 thời điểm 1 container chỉ có thể dùng 1 network thôi, mặc dù chúng ta có thể add nhiều network vào container)

&nbsp;

### 📎 Phase 4: Run app using docker-compose

&nbsp;
Sau khi hiểu được 3 giai đoạn phía trên, thì việc viết `docker-compose` chỉ là công việc tổ hợp lại các bước trên một cách ngắn gọn

1. Tạo một file `docker-compose.yml` cùng cấp với `Dockerfile`
2. Nội dung file `docker-compose.yml` như sau:
```sh
version: "3.9"

services:
    node-app:
        build:
            context: .
        environment: 
            - DB_HOST=mysqldb
            - DB_USER=seminar_sgroup
            - DB_PASSWORD=root
            - DB_NAME=123123
        restart: always
        ports:
            - 3001:3000
        depends_on: 
            - mysqldb
        networks: 
            - backendnetwork
    mysqldb:
        image: mysql:8.0.25
        restart: always
        command: --default-authentication-plugin=mysql_native_password
        environment: 
            - MYSQL_ROOT_PASSWORD=123123
        volumes: 
            - ./migrations/:/docker-entrypoint-initdb.d
            - ./storage:/var/lib/mysql
        networks: 
            - backendnetwork

networks: 
    backendnetwork:
        driver: bridge
```

> Note: Để truy cập terminal của 1 container thì có thể dùng lệnh sau: docke  exec -it <container-id>

[sgroup-logo]: https://res.cloudinary.com/dgext7ewd/image/upload/v1622822649/github-profile/small-sgroup-logo_p0xwbb.png


