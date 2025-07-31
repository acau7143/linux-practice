# 🧠 check_mem_usage.sh 설명

## 📌 목적

- **전체 시스템의 메모리 사용량** 또는
- **특정 프로세스 이름**을 입력했을 때 해당 프로세스들의 **총 메모리 사용량**을 계산합니다.
- `ps`, `awk`, `paste`, `bc` 등의 기본 명령어를 활용하여 **간단한 시스템 모니터링 도구**를 구현합니다

---

## 🧪 스크립트 코드

전체 코드는 [scripts/check_mem_usage.sh](scripts/check_mem_usage.sh) 참조.

---

## 🔍 명령어 구성 설명

```bash
ps -eo pmem,comm
```

| 옵션 | 의미 |
| --- | --- |
| `-e` | 모든 프로세스 출력 (`--everyone`) |
| `-o pmem,comm` | 출력할 열 지정. `pmem`: 메모리 사용률, `comm`: 실행 중인 명령어 이름 |

## ✅ `ps`에서 헤더 제거하는 공식 방법

```bash
ps -eo pmem=,comm=
```

여기서 `=`는 **열 이름(헤더)을 제거**하겠다는 의미입니다.

---

### 📌 비교

| 목적 | 명령어 |
| --- | --- |
| 헤더 포함 | `ps -eo pmem,comm` |
| 헤더 제거 | `ps -eo pmem=,comm=` |

또는

```bash
ps -eo pmem,comm | grep -v "%MEM COMMAND"
```

처럼 `grep -v`로 수동 제거도 가능하지만, `ps` 자체 기능이 더 깔끔합니다.

---

## ✅ paste 명령어

```bash
paste -sd+ file
```

| 구성 | 설명 |
| --- | --- |
| `paste` | 여러 줄을 병합하는 명령어 |
| `-s` (`--serial`) | 여러 줄을 **한 줄로 직렬 변환** |
| `-d+` | 줄 사이에 **`+` 기호를 구분자로 삽입** |
---
##`bc`
 리눅스/유닉스에서 사용하는 기본 계산기 프로그램입니다.

### 2. **한 줄로 계산**

```bash
echo "3 + 5 * 2" | bc
```

📤 출력:

```
13
```

---


## ✅ 의미: `grep -w -e`

`grep -we [패턴]`은 아래와 동일합니다:

```bash
grep -w -e "패턴"
```

| 옵션 | 설명 |
| --- | --- |
| `-w` | **단어 전체 일치** (단어 경계 기준으로 정확히 일치하는 줄만 찾음) |
| `-e` | **검색할 패턴을 명시** (여러 패턴 지정할 때 사용 가능) |

## 📌 예제

### 📁 파일 (`words.txt`)

```
apple
apples
pineapple
apple pie
grape
```

### 🔎 명령어

```bash
grep -we "apple" words.txt
```

📤 출력:

```
apple
apple pie
```

- ✅ `apple`은 단어 단독이므로 매치됨
- ✅ `apple pie`도 `apple`이라는 단어가 **공백으로 구분**돼 있으므로 매치됨
- ❌ `apples`나 `pineapple`은 단어 경계가 맞지 않아 제외됨
