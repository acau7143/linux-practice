# 쿠버네티스 제어설정 / ip 변경 / kubectl

## worker 노드에서 kubectl 동작 시키기

```bash
1번째 방법
# Master 노드의 설정 파일 복사하기
$ cat /etc/rancher/k3s/k3s.yaml

# Worker 노드 기준 설정파일 생성
# 아래 server: 설정 값내용을 변경
# 변경이전: 127.0.0.1
# 변경이후: 마스터노드 IP 주소
$ sudo mkdir /etc/rancher/k3s/
$ sudo vim /etc/rancher/k3s/k3s.yaml
...
    server: https://"마스터 노드 IP 주소":6443
...

# kubectl 명령어 확인
$ kubectl get node
$ kubectl get pods

2번째 방법
# Master 노드의 설정 파일 복사하기
$ cat /etc/rancher/k3s/k3s.yaml

# 추가적인 kubectl 설정 방법
$ sudo vim ~/.kube/config
...
    server: https://"마스터 노드 IP 주소":6443
...

# 환경변수 KUBECONFIG 지정
$ vim ~/.bashrc
...
export KUBECONFIG=~/.kube/config
$ source ~/.bashrc

# 테스트
$ kubectl get pods
```

## master ip 주소 변경하기

만약에 다른 장소에서 접속하거나, 마이그레이션 하면서 ip 주소가 바뀌게 되는 상황에 사용함

```bash
# 데몬 프로세스 k3s 설정 변경하기
# --node-ip 옵션으로 현재 사용중인 IP 주소 지정
# 예: 192.168.0.201
$ sudo vim /etc/systemd/system/k3s.service
...
ExecStart=/usr/local/bin/k3s \
    server --node-ip 192.168.0.201 \

# 설정 적용 후
$ sudo systemctl enable k3s
$ sudo systemctl restart k3s
$ sudo chmod +r /etc/rancher/k3s/k3s.yaml

# Master 노드 IP 주소 확인하기
$ kubectl get node -o wide

```

## worker ip 주소 변경하기

```bash
# Master 노드(서버)를 기준으로
# Worker 노드 삭제후
# 토큰 내용 복사하기
$ kubectl delete node sub-node
$ sudo cat /var/lib/rancher/k3s/server/node-token

# Worker 노드 기준
# 데몬 프로세스 k3s-agent 설정 변경하기
# --node-ip 옵션으로 현재 사용중인 IP 주소 지정
# 예: 192.168.0.202
$ sudo vim /etc/systemd/system/k3s-agent.service
...
ExecStart=/usr/local/bin/k3s \
    agent --node-ip 192.168.0.202 \
    --server https://"Master 노드 IP 주소":6443 \
    --token "Master 노드 토큰값"

# 설정 적용 후
$ sudo systemctl enable k3s-agent
$ sudo systemctl restart k3s-agent

# Master 노드 IP 주소 확인하기
$ kubectl get node -o wide

```

## kubectl 명령어

```bash
# pod, replicaset, deployment, service 조회 
$ kubectl get all

# node 조회
$ kubectl get no
$ kubectl get node
$ kubectl get nodes

# 결과 포멧 변경
$ kubectl get nodes -o wide
$ kubectl get nodes -o yaml
$ kubectl get nodes -o json

# 노드 상세 정보 살펴보기 
$ kubectl describe node <node name>  
$ kubectl describe node/<node name>

# 현재 쿠버네티스 진행상황 살펴보기
$ kubectl get events
$ kubectl get events -o wide | less

# pod 내부에서 명령어 실행하기
$ kubectl exec -it <POD_NAME> -- <COMMAND>

# pod의 컨테이너를 위한 로그 출력
$ kubectl logs -f <POD_NAME|TYPE/NAME> 

# yml파일 등을 통한 실행
$ kubectl apply -f <FILENAME>
# yml 파일 등을 통한 삭제
$ kubectl delete -f <FILENAME>
```