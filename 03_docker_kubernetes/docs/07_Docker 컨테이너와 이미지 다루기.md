# Docker 컨테이너와 이미지 다루기
```
container도 프로세스이다.

docker attach - bash나 shell process의 running 중인 프로세스에 접속가능한 명령어

docker ps -q : 실행중인 container 들의 pid를 보여줌 
docker stop $(docker ps -q) : 한번에 docker process들 멈추게 가능
docker rm $(docker ps -qa) : 한번에 종료중인 container를 지워버리는 명령어

```

## 실습

```bash
# 해당 컨테이너에 접속해서 변경분(test 폴더) 만들어보기
$ docker attach 05fe6f4bb576
root@05fe6f4bb576:/# 
root@05fe6f4bb576:/# cd home/
root@05fe6f4bb576:/home# mkdir test
root@05fe6f4bb576:/home# exit
exit

# 변경된 컨테이너 내용 확인하기
# C: Changed
# A: Added
# D: Deleted
$ docker diff 05fe6f4bb576
C /root
A /root/.bash_history
C /home
A /home/test

```

## diff를 했을 때 D가 나오게 하는 방법

```bash
root@107afa0fd0d3:/home# rm -r test/
root@107afa0fd0d3:/home# ls
root@107afa0fd0d3:/home# exit
exit
reallinux@project:~$ docker diff 107afa0fd0d3
C /root
A /root/.bash_history

# 이렇게 하면 D가 나올 줄 알았으나 나오지 않음 
# 이유는 images의 원본이 달라지지 않았기 때문 test는 우리가 만든 디렉토리이기 때문에

root@107afa0fd0d3:/# rm -r media/
root@107afa0fd0d3:/# exit
exit
reallinux@project:~$ docker diff 107afa0fd0d3
C /root
A /root/.bash_history
C /home
A /home/test
D /media
```

## commit 실습

```bash
# docker commit은 실행 중이거나 중지된 컨테이너의 현재 상태를 기반으로 새로운 이미지(image)를 만든다 

$ docker commit 05fe6f4bb576 ubuntu-test
sha256:38fc92a6c7beaca12ba85c66ccd479fdcfb2ba90b95ca11848dd7e64950f89cc
$ docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
ubuntu-test                 latest              38fc92a6c7be        5 seconds ago       122MB
ubuntu                      16.04               b9409899fe86        11 days ago         122MB
mysql                       5.7                 cd3ed0dfff7e        13 days ago         437MB
redis                       latest              de25a81a5a0b        13 days ago         98.2MB
...

# 새롭게 만든 ubuntu-test 이미지를 통해서 container 실행하기
$ docker run -it -d ubuntu-test
414226e176eb72e29d9616ebfdfb3646963022b4f318283e40d1782c7a5ea0f1

# 아까 테스트로 만들어둔 폴더 확인하기
$ docker attach 414226e176
root@414226e176eb:/#
root@414226e176eb:/# ls home
test
root@414226e176eb:/#

```