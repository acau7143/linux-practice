# 스케줄러: 특정 node에 pod  할당하기

## kubectl get node가 안됌

```
/etc/rancher/k3s/k3s.yaml은 사용자가 관리하는 설정 파일이 아니라
k3s server가 실행될 때마다 자동으로 재생성하는 출력 파일이므로,
chmod 또는 vim으로 수정해도 즉시 원래 상태로 복구된다.
```

## 해결

```
왜 문제가 났냐 저번 실습 떄  --node-ip 192.168.0.201로 IP를 고정해둠
지금은 DHCP 때문에 IP가 바뀜 (예: .59)
k3s는 없는 IP로 서버를 띄우려다 실패
그래서 실행 → 바로 종료 → systemd 재시작 반복 (activating)
왜 chmod 해도 안 됐냐 권한 문제가 아니라 API 서버 자체가 안 떠 있었음

그래서 초기설정으로 될돌려 놓음
```

얻게 된점 : 오류를 보고 당황하지 말고 내가 전에 무슨 설정을 건드렸는지 기억해보기 대부분 되다가 안되는부분은 내가 건드렸다가 안될 확률이 높다.

## master 노드와 worker 노드에 각각 라벨 설정하기

```bash
# 마스터 노드 기준으로 라벨설정
# 예시: 서버가 CPU 특화 되어있다는 의미의 라벨
$ kubectl label node ubuntu type=cpu
$ kubectl describe node ubuntu | less

# Worker 노드 기준으로 라벨설정
# 예시: 서버가 GPU 특화 되어있다는 의미의 라벨
$ kubectl label node sub-node type=gpu
$ kubectl describe node sub-node | less

```

## deployment 배포하기

```bash
# 현재 실행중인 Pod 삭제하기
$ kubectl delete -f web-server-replicaset.yaml

# yaml 파일 생성하기
$ vim web-server-deploy.yaml
$ cat web-server-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server-rs
spec:
  replicas: 5

  selector:
    matchLabels:
      app: webapp
      tier: app
  template:
    metadata:
      labels:
        app: webapp
        tier: app
    spec:
      containers:
        - name: web-server
          image: reallinux/web-server:1
          ports:
            - containerPort: 80
              protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: web-server
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: 80
      protocol: TCP
      nodePort: 31000
  selector:
      app: webapp
      tier: app

# yaml 파일을 통해서 Pod 실행하기
$ kubectl apply -f  web-server-deploy.yaml
# 참고 : yaml 파일을 통해서 Pod 삭제
$ kubectl delete -f  web-server-deploy.yaml

# Pod 와 ReplicaSet 확인
$ kubectl get pods,rs
```

## cpu 중심적인 서버 노드 pod 생성하기

```bash
# 쿠버네티스 API server 를 통해서 적용할 Object Spec  yaml 파일 생성
# type=cpu 인 노드에만 스케줄링 될 수있도록 적용
$ vim web-server-deploy.yaml
...
    spec:
      containers:
        - name: web-server
          image: reallinux/web-server:1
          ports:
            - containerPort: 80
              protocol: TCP
      nodeSelector: 
        type: cpu
...

# 적용 후 확인하기
$ kubectl apply -f web-server-deploy.yaml
$ watch -n 0.1 kubectl get pods -o wide   apiVersion: apps/v1

```

## cpu,gpu 중심적인 서버에 pod 생성하기

```bash
# 쿠버네티스 API server 를 통해서 적용할 Object Spec  yaml 파일 생성
$ vim web-server-deploy.yaml
...
    spec:
      containers:
        - name: web-server
          image: reallinux/web-server:1
          ports:
            - containerPort: 80
              protocol: TCP
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                 - key: type
                   operator: In
                   values:
                    - cpu
                    - gpu
...
# 적용 후 확인하기
$ kubectl apply -f web-server-deploy.yaml
$ watch -n 0.1 kubectl get pods -o wide   apiVersion: apps/v1
```