# Docker를 통한 cgroup 분석: CPU 코어제한/메모리 제한

## cpu 코어 제한 실습

```bash
# --cpuset-cpus=0,1 : 0, 1번째 cpu를 할당한다
# 결과적으로 CPU 코어 2개 로 제한
$ docker run --cpuset-cpus=0,1 -it ubuntu:18.04 /bin/bash  

# 다른 터미널에서 top 로 cpu 점유율 모니터링 준비
$ top

# 도커로 실행한 해당 컨테이너 터미널에서
# sysbench 와 htop 프로그램을 설치하자
root@600fe864ca9b:/# apt update && apt install sysbench htop  

# CPU 테스트 (소수계산) 진행한다
root@600fe864ca9b:/# sysbench --test=cpu run

# 다른터미널에서 top 도 확인하기 (하나의 CPU 코어만 100% 예상)

# CPU 테스트 (소수계산) 진행한다
# Thread 두개 생성해서 (결과적으로 코어 2개 활용 가능)
root@600fe864ca9b:/# sysbench --test=cpu --num-threads=2 run

# 다른터미널에서 top 도 확인하기 (두개의 CPU 코어 활용예상) 
```

## 메모리 사용율 제한

```bash
# 메모리 차지하는 python 스크립트 작성하기  
$ vim mem_eater.py
$ cat mem_eater.py
f = open("/dev/urandom", "r")
data = ""

i=0
while True:
    data += f.read(10000000) # 10mb
    i += 1
    print "%dmb" % (i*10,)

# 일반테스트 후  Ctrl + c 키로 종료 
$ python mem_eater.py

# 물리메모리 100MB 에 스왑을 사용하지 않는 제한 하기
$ sudo docker run --memory=100M --memory-swappiness 0 -it ubuntu:18.04 /bin/bash    

# 지난 실습 mem_eater.py 테스트
root@600fe864ca9b:/# apt update && apt install vim python
root@600fe864ca9b:/# vim mem_eater.py
root@600fe864ca9b:/# python mem_eater.py
```