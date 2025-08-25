# 리눅스 스케줄링 period 란?

## period : 분배할 cpu 실행시간 단위

## 스케쥴러 period 프로세스들에게 분배할 CPU 총시간

```bash
# 분배할 CPU 총시간 period 기본값 100ms
cat /sys/fs/cgroup/cpu/cpu.cfs_period_us

# 모든 프로세스는 기본 cgorup 설정에 적용이 되어있다.
# cgroup (HW 자원 독립 / 제한 기능)
# CPU 기본 cgroup 설정에 포함되어 있는 프로세스 PID 들 확인
cat /sys/fs/cgroup/cpu/tasks

#유저 프로세스 기준 cgroup 에서 현재 프로세스 PID 확인
cat /sys/fs/cgroup/cpu/user.slice/tasks | grep $$

# ** 모든 프로세스는 기본 cgroup에 포함이 된다. **
```

![04_1.png](04_1.png)

---

## 스케줄러 sched_min_granularity 최소 timeslice 확인

```bash
# nanosecond 단위 (ns)
# 2,250,000 ns = 2.25 ms
cat /proc/sys/kernel/sched_min_granularity_ns

# 분배할 CPU 총시간 period 기본값 100ms 이기 때문에
# 총 100ms 중에서 한 프로세스당 최소 2.25 ms 는 보장해준다.
# 프로세스가 무한이 많아져도 보장
cat /sys/fs/cgroup/cpu/cpu.cfs_period_us

```

![04_2.png](04_2.png)

## 프로세스 실행한 runtime 확인하기

```bash
watch -n 0.1 cat /proc/$$/sched
```

이걸 입력하면:

- `$$`는 **명령 실행 시점에** **현재 bash 프로세스 PID**로 치환됨.
    
    예: `/proc/1234/sched`
    
- 이후 실행되는 `watch` 명령은 0.1초마다 `cat /proc/1234/sched`를 호출하게 됨.

즉, **/proc/1234/sched**는 `bash` 프로세스(1234번)의 스케줄링 정보.

---

## 2. CPU를 누가 쓰는지

- **watch** 프로세스: 타이머 돌리고, 주기마다 fork/exec
- **cat** 프로세스: /proc 파일 읽어서 화면에 출력
- **bash** 프로세스: watch를 실행시킨 후 **그냥 대기**

---

## 3. 그래서 runtime이 안 바뀌는 이유

`sum_exec_runtime`은 "해당 PID가 CPU에서 실제로 실행된 누적 시간"입니다.

- 우리가 보고 있는 건 `/proc/1234/sched` → **bash**의 runtime
- bash는 watch 실행 이후 **아무 일도 안 함** → runtime이 거의 그대로
- watch와 cat이 CPU를 쓰더라도, 그건 **PID 5678(watch)**, **PID 5679(cat)**에서 발생하므로
    
    bash(1234)의 runtime에는 반영되지 않음.