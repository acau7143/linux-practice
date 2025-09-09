# 선점(preemp)과 시그널 처리 추적


현재 task 입장 : CPU를 빼앗긴다 (선점 당한다.)

# 📌 리눅스 시그널 처리 요약

## 1. 시그널(signal) 이란?

- 프로세스에게 비동기적으로 보내는 **알림/명령**
- 예:
    - `SIGKILL(9)` → 강제 종료
    - `SIGINT(2)` → Ctrl+C
    
    - `SIGCHLD(17)` → 자식 프로세스 종료 알림

---

## 2. 처리 흐름 (2단계)

1. **Generate (enqueue)**
    - 시그널이 발생하면, 커널이 대상 프로세스의 **task_struct → sigpending** 큐에 등록만 함.
    - 예: `kill -9 1234` → PID 1234 프로세스의 sigpending에 SIGKILL 기록.
2. **Deliver (dequeue)**
    - 프로세스가 다시 실행될 때, 커널이 "pending signal 있나?" 확인.
    - 있다면 `sighand_struct` 참고:
        - 핸들러 등록 O → 해당 함수 실행
        - 핸들러 등록 X → 기본 동작(종료, 무시 등)

---

## 3. 관련 구조체

- **task_struct**: 프로세스 정보(PCB). 시그널 관련 자료도 들어 있음.
- **sigpending**: 도착했지만 아직 처리되지 않은 시그널 목록.
- **sighand_struct**: "시그널 오면 뭘 할지" 규칙표 (기본 동작 or 핸들러 함수 포인터).

---

## 4. 핸들러 동작

- 커널이 deliver 단계에서 `handle_signal()` 호출 → 사용자 핸들러(`handle_sigint`) 실행.
- 끝나면 **sigreturn() 시스템콜**로 원래 실행 위치 복구.

👉 즉, "내 코드 실행하다가 → 강제로 handler 실행 → 끝나면 sigreturn 통해 원래 코드 복귀".

---

## 5. ftrace로 본 시그널

- `signal_deliver`: 프로세스에 시그널이 실제 적용되는 순간 (ex: top이 SIGKILL 받음).
- `signal_generate`: 다른 프로세스에게 새 시그널 생성하는 순간 (ex: top이 죽으면서 bash에 SIGCHLD 보냄).

---

## 6. 비유

- **sigpending** = 문 앞에 쌓인 택배 (시그널 도착했지만 아직 열지 않음).
- **sighand_struct** = 택배 설명서 (받으면 어떻게 처리할지).
- **generate** = 택배 도착.
- **deliver** = 집에 들어와서 택배 열고 설명서대로 처리.
- **sigreturn** = 처리 끝나고 책 읽던 자리로 복귀.

---

✅ **핵심 한 줄 요약**

리눅스 시그널은 먼저 **등록(generate)** → 실행 시점에 **전달(deliver)** → 필요시 **핸들러 실행 후 sigreturn으로 복귀** 한다.

## 4번 핸들러 추가 설명

## 1. 원래 코드 실행 중

예를 들어 내가 만든 프로그램이 이렇게 실행되고 있다고 합시다:

```c
int main() {
    while (1) {
        printf("작업 중...\n");
        sleep(1);
    }
}

```

프로세스는 지금 **while 루프** 안에서 계속 `printf`를 찍으면서 잘 돌고 있어요.

---

## 2. 시그널 도착 (deliver)

내가 터미널에서 `kill -2 <PID>` → 즉 **SIGINT**를 보냄.

커널은 “이 프로세스에 SIGINT 시그널이 도착했구나” 하고 확인합니다.

이때 만약 내가 프로그램에서 이렇게 등록해놨다면:

```c
signal(SIGINT, handle_sigint);

```

커널은 `sighand_struct`를 보고,

“SIGINT 오면 `handle_sigint()` 함수 실행해야겠네” 하고 결정합니다.

---

## 3. 강제로 handler 실행

지금 CPU는 원래 `while` 루프 안에서 `printf` 실행 중이었죠?

커널은 여기서 잠깐 흐름을 멈추고,

**내 코드 대신에 `handle_sigint()` 함수로 점프시킵니다.**

```c
void handle_sigint(int signo) {
    printf("SIGINT 받음!\n");
}

```

그래서 갑자기 내 프로그램은 `handle_sigint()` 실행을 시작합니다.

---

## 4. sigreturn으로 복귀

`handle_sigint()` 함수가 끝나면 그냥 `return` 하는 게 아니라,

자동으로 **`sigreturn()` 시스템콜**을 호출하게 됩니다.

왜냐하면 커널이 **시그널 핸들러 들어가기 전에 원래 레지스터, 스택 상태를 저장**해놨기 때문이에요.

sigreturn이 그 상태를 복원해야만, **원래 실행하던 `while` 루프 자리로 정확히 돌아갈 수 있습니다.**

즉:

- `handle_sigint()` → "시그널 대응 행동"
- `sigreturn()` → "이제 핸들러 끝났으니, 네가 하던 코드 자리로 복귀"

---

## 🔑 한 줄로 요약

프로그램은 원래 코드 실행 중이지만,

**시그널이 오면 커널이 강제로 흐름을 꺾어서 핸들러로 진입시킨 뒤,
sigreturn을 통해 원래 코드 위치로 정확히 복귀시킨다.**