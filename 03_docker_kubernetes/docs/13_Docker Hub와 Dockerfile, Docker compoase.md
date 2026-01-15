# Docker Hub와 Dockerfile, Docker compoase

생성 일시: 2026년 1월 15일 오후 12:42
최종 편집 일시: 2026년 1월 15일 오후 2:44

## docker hub와 image 업로드

![image.png](image.png)

![image.png](image%201.png)

![image.png](image%202.png)

![image.png](image%203.png)

![image.png](image%204.png)

```
dockerfile 없이 리눅스를 관리한다는 것은 굉장히 비효율적으로 관리한다고 볼 수 있다.
어떠한 설정, 설치를 했는지 역추적이 dockerfile로 가능해지기 때문에 유지보수하기에 편리하다.
```

```
dockerfile 구성요소

1. 가장 중요한건 from과 run 부분

2. RUN과 CMD는 목적이 다르다. cmd는 dockerfile의 밑에 위치하게 되고 container 실행 defualt 명령어 지정하게 되는데 
  지정되어 있지 않으면 마지막으로 실행된 run을 기준으로 적용되어 질 수 있다.
  container 가 여러 프로세스 일 수 있는데 main이 되는 프로세스를 지정할 때 CMD 명령어로 지정할 수 있게 된다.

3. ARG로 변수를 지정하면 dockerfile이 실행 될 때 이미지가 빌드 되는 순간에만 쓰이게 된다. 
   ENV는 환경변수 값이 이미지에 저장되며 컨테이너 실행 시에도 유지된다.
   
docker build = 빌드 시점

docker run = 실행 시점

ARG → build only

ENV → build + run
```

![image.png](image%205.png)

```
Dockerfile에 명시된 각 명령어는 위에서 아래로 한 줄씩 실행되며
각 명령어마다 하나의 이미지 레이어를 생성하여 최종적으로 하나의 이미지가 만들어진다.
```

## **Dockerfile 을 활용해서 uftrace 를 위한 컨테이너(리눅스) 를 만들기**

```bash
# uftrace 오픈소스 다운받기
$ git clone https://github.com/namhyung/uftrace.git  

# uftrace 폴더로 이동
$ cd uftrace

# uftrace 오픈소스에서 Dockerfile 찾기
$ find ./ -name Dockerfile

# uftrace Dockerfile 을 통해서 리눅스 환경 이미지 만들기
$ cd misc/docker/ubuntu/18.04
$ docker build .

```

## dockercompose 실습

```
docker compose -> 여러개의 컨테이너 동시제어
이제는 docker 오케스트레이션 이나 쿠버네티스를 이용해서 편리하게 가능하기에 기능만 알아보자

```

```bash
$ vim Dockerfile
$ cat Dockerfile
FROM drupal:8.8.2

RUN apt-get update && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/themes

RUN git clone --branch 8.x-3.x --single-branch --depth 1 https://git.drupal.org/project/bootstrap.git \ 
    && chown -R www-data:www-data bootstrap

WORKDIR /var/www/html

$ vim docker-compose.yml
$ cat docker-compose.yml
version: '2'

services:

  drupal:
    image: custom-drupal
    build: .
    ports:
      - "8080:80"
    volumes:
      - drupal-modules:/var/www/html/modules
      - drupal-profiles:/var/www/html/profiles       
      - drupal-sites:/var/www/html/sites      
      - drupal-themes:/var/www/html/themes
 
  postgres:
    image: postgres:12.1
    environment:
      - POSTGRES_PASSWORD=mypasswd
    volumes:
      - drupal-data:/var/lib/postgresql/data

volumes:
  drupal-data:
  drupal-modules:
  drupal-profiles:
  drupal-sites:
  drupal-themes:

# docker compose 폴더 생성 후 이동     
$ mkdir docker-compose-test
$ cd docker-compose-test

# docker compose 폴더로
# Dockerfile 이동
# docker-compose.yml 이동
$ mv ../Dockerfile ./
$ mv  docker-compose.yml ./

# docker compose 실행
$ docker-compose up -d

# docker compose 로 실행한 2개의 컨테이너 확인
$ docker-compose ps

# docker compose 로 실행한 2개의 컨테이너 정지
$ docker-compose stop

# docker compose 로 실행한 2개의 컨테이너 시작
$ docker-compose start

# docker compose 실행종료
$ docker-compose down
```