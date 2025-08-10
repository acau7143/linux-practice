# top 명령어를 통한 시스템 세부 정보 파악하기

# 시스템 정보

## 컴퓨터 켜놓은 시간(uptime)

명령어 uptime 과 동일한 결과를 보여줌

![image.png](images/image.png)

---

## 시스템 부하상태(loadavg)

```
코어 갯수를 알아야 정확히 알 수 있다 (명령어  nproc)

결론 요약
Load Average는 CPU 사용률뿐만 아니라, 실행 중인 상태(R), 
디스크 대기 상태(D)를 포함한 전체 시스템 부하를 보여줍니다. 
그리고 이를 해석하려면 반드시 nproc으로 CPU 코어 수를 확인해야 합니다.

cat /proc/loadavg : 똑같은 결과 얻기 가능

```

![image.png](images/image%201.png)

---

## 프로세스(task) 상태별 개수 정보

```
top 명령어에서 Tasks: total 수와 상태별 합이 다른 경우,
그것은 I 상태 (idle 커널 쓰레드) 가 total에서 제외되기 때문입니다.
I는 S처럼 보이지만 엄밀히 말해 별도 상태이며, total이나 sleeping에 포함되지 않습니다.

* 좀비프로세스: 자식프로세스가 종료가
되었는데 부모가 wait()시스템콜을 통해서
자식프로세스의 커널데이터(프로세스 관리용도데이터 task_struct ...) 해지(free)하지 않았을때

* 고아프로세스: 부모프로세스가 먼저 종료가 되어서 부모가 없는 자식프로세스
(pid 1 번 init 프로세스가 부모가 된다)
```

## 비교 요약표

| 구분 | 좀비 프로세스 (Zombie) | 고아 프로세스 (Orphan) |
| --- | --- | --- |
| 정의 | 자식이 종료됐지만 부모가 `wait()` 호출 안 함 | 부모가 먼저 종료된 자식 |
| 상태 | `Z (Zombie)` 상태로 남음 | `init(1)`이 부모가 되어 관리 |
| 해결 방법 | 부모가 `wait()` 호출해야 함 | init/systemd가 자동 처리 |
| 시스템 영향 | 너무 많으면 PID 고갈 가능 | 일반적으로 문제 없음 |

![image.png](images/image%202.png)

---

## CPU 사용를

### 네트워크에서 예시

1. **패킷 도착** → NIC가 **Hard IRQ**로 CPU에게 알려요. ("패킷 왔어요!")
2. CPU는 **잠깐 응답**하고 → 자세한 처리는 **Soft IRQ**한테 넘겨요.
3. Soft IRQ는 그 패킷을 분석하고, 복사하고, 응용 프로그램으로 넘겨요.

---

### IRQ 

| 항목 | Hard IRQ | Soft IRQ |
| --- | --- | --- |
| 누가 호출? | 하드웨어 (장치) | 소프트웨어 (커널) |
| 언제? | 이벤트 발생 즉시 | 나중에 CPU가 여유 있을 때 |
| 예시 | 패킷 도착, 키보드 입력 | 패킷 처리, 복사, 분석 |
| 특징 | 빠르게 반응, 가볍게 처리 | 무거운 일, 천천히 처리 |

![image.png](images/image%203.png)

---

## MEM 사용율

```
free
```

![image.png](images/image%204.png)

---

# 프로세스별 세부 정보

![image.png](images/image%205.png)

![image.png](images/image%206.png)