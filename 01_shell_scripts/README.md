# 🐚 03_shell_scripts

Shell Script 실습 폴더입니다.  
각 스크립트의 설명은 동일한 이름의 `.md` 파일에 정리되어 있습니다.

---

## 📄 스크립트 목록

| 스크립트 이름             | 설명                                | 문서 보기                                      |
|---------------------------|-------------------------------------|------------------------------------------------|
| `git_commit_count.sh`     | 연도별 커밋 수를 파일별로 분석       | [docs/git_commit_count.md](docs/git_commit_count.md)   |
| `check_mem_usage.sh`      | 전체 또는 특정 프로세스 메모리 사용량 확인 | [docs/check_mem_usage.md](docs/check_mem_usage.md)     |
| `check_kernel_task.sh`    | 커널 스레드(PF_KTHREAD) 식별 스크립트     | [docs/check_kernel_task.md](docs/check_kernel_task.md) |

---

## 🛠 실행 방법 예시

```bash
bash git_commit_count.sh         # 현재 연도 기준 분석
bash git_commit_count.sh 2023    # 특정 연도 기준 분석

bash check_mem_usage.sh          # 전체 메모리 사용량 출력
bash check_mem_usage.sh nginx    # 'nginx' 프로세스 메모리 사용량 출력

bash check_kernel_task.sh        # 커널 태스크 목록 출력
