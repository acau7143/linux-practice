# Docker save/load, export/import 통한 이미지 다루기

## **docker save 명령을 통해서 이미지 tar파일로 저장하기**

```bash
# docker save / export / import 테스트용 폴더 만들기  
$ mkdir ~/docker_tar
$ cd docker_tar

# docker save 명령을 통해서 이미지 파일 저장하기
$ docker save ubuntu:16.04 -o ubuntu.tar

# tar 파일 확인하기
$ file ubuntu.tar

# tar 파일 해제
$ mkdir ubuntu
$ tar -C ubuntu -xvf ubuntu.tar

# ubuntu.tar 파일 내용 확인하기
$ tree ubuntu/
```

## **docker load 명령을 통해서 tar파일 image 파일로 로드**

```bash
# docker load 명령 살펴보기
$ docker load --help

Usage:	docker load [OPTIONS]

Load an image from a tar archive or STDIN

Options:
  -i, --input string   Read from tar archive file, instead of STDIN  
  -q, --quiet          Suppress the load output
  
# 이전실습에서 생성했던 ubuntu.tar 를 이미지로 만들기  
$ docker load -i ubuntu.tar 

# 이미지 리스트에서 Load 제대로 되었는지 확인하기
$ docker images

```

## **docker export 명령을 통해서 컨테이너의 filesystem tar파일로 저장하기**

```bash
# 

# docker export 명령 살펴보기
$ docker export --help

Usage:	docker export [OPTIONS] CONTAINER

Export a container''s filesystem as a tar archive

Options:
  -o, --output string   Write to a file, instead of STDOUT 
  
  # docker save / export / import 테스트용 폴더로 이동  
$ cd ~/docker_tar

# ubuntu:16.04 이미지 파일로 생성된 컨테이너 중에서
$ docker container list -a | grep ubuntu | head -1

# 첫번째 컨테이너 ID 얻어 오기 (예시: ab774ba112a4)
$ docker container list -a | grep ubuntu | head -1 | awk '{print $1}'  
ab774ba112a4

# 컨테이너 ID값으로 docker export 하기 (예시: ab774ba112a4)  
$ docker export ab774ba112a4 -o ubuntu_fs.tar

# tar 파일 확인하기
$ file ubuntu_fs.tar

# tar 파일 해제
$ mkdir ubuntu_fs
$ tar -C ubuntu_fs -xvf ubuntu_fs.tar

# ubuntu_fs.tar 파일 내용 확인하고 ubuntu.tar 내용과 비교하기
$ tree ubuntu_fs/

결과
# export한 파일
tree -L 1 ubuntu_fs
ubuntu_fs
├── bin
├── boot
├── dev
├── etc
├── home
├── lib
├── lib64
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── srv
├── sys
├── tmp
├── usr
└── var

# save한 파일
tree -L 1 ubuntu
ubuntu
├── blobs
├── index.json
├── manifest.json
└── oci-layout

```

## **docker import 명령을 통해서 tar파일을 이미지로 만들기**

export로 했거나 아니면 rootfs 내용을 tar로 압축한 것만 import가 가능하다.

```bash
# docker import 명령 살펴보기
$ docker import --help

Usage:	docker import [OPTIONS] file|URL|- [REPOSITORY[:TAG]]

Import the contents from a tarball to create a filesystem image

Options:
  -c, --change list      Apply Dockerfile instruction to the created imag  e
  -m, --message string   Set commit message for imported image

# 이전실습에서 생성했던 ubuntu_fs.tar 를 이미지로 만들기  
$ docker import ubuntu_fs.tar reallinux:16.04 

# 이미지 리스트에서 Load 제대로 되었는지 확인하기
$ docker images

```

## 🔥 핵심 차이 표 (암기용)

| 구분 | save | export |
| --- | --- | --- |
| 대상 | image | container |
| 레이어 | ⭕ 유지 | ❌ 제거 |
| 메타데이터 | ⭕ | ❌ |
| CMD / ENV | ⭕ | ❌ |
| 복원 명령 | docker load | docker import |
| 실무 사용 | ⭐⭐⭐⭐ | ⭐ |

---

## 면접용 한 줄 답변

> “docker save는 이미지와 레이어·메타데이터를 그대로 보존해 백업·이동할 때 사용하고,
> 
> 
> `docker export`는 컨테이너의 최종 파일시스템만 추출해 경량화나 OS 템플릿 용도로 사용합니다.”
> 

## 📊 한눈에 비교 (암기표)

| 구분 | import | load |
| --- | --- | --- |
| 입력 | rootfs tar | image tar |
| 대상 | 파일시스템 | Docker image |
| 메타데이터 | ❌ | ⭕ |
| 레이어 | ❌ | ⭕ |
| CMD / ENV | ❌ | ⭕ |
| 용도 | 마이그레이션 | 백업/복구 |

---

## 제일 중요한 개념

> “docker export/import는 컨테이너의 root filesystem을 이미지화하는 방식이고,
> 
> 
> `docker save/load`는 Docker 이미지 자체를 그대로 백업·복원하는 방식입니다.”
>