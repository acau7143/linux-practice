# service/ReplicaSet/Deployment 와 장애복구 테스트

## Pod과 service 세팅

```bash
# yaml 파일 생성하기
$ vim web-server-pod-svc.yaml
$ cat web-server-pod-svc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server
  labels:
    app: webapp
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

# yaml 파일을 통해서 Pod 실행하기
$ kubectl apply -f web-server-pod-svc.yaml
# 참고 : yaml 파일을 통해서 Pod 삭제
$ kubectl delete -f web-server-pod-svc.yaml

# Pod 와 Service 확인
$ kubectl get pods,service

# Pod의 IP 주소로 직접 웹서버 요청 테스트
$ kubectl describe pod web-server | grep IP | head -1
IP:           10.42.3.31
$ curl 10.42.3.31
Hello World !

# 호스트에서 직접 웹서버 요청 테스트 (Node Port)
$ curl localhost:31000
Hello World !

# Service 의 Cluster IP 주소 알아내기
$ kubectl get service
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP,80/TCP   167m
web-server   NodePort    10.43.37.111   <none>        8080:31000/TCP   14m

# Service 의 Cluster IP 주소로 웹서버 요청 테스트
$ curl 10.43.37.111:8080
Hello World !
```

### cluster ip 주소로 웹 서버 요청을 하기 위해서는 포트 번호를 붙어야 한다.

```bash
reallinux@project:~$ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.43.0.1       <none>        443/TCP          103m
web-server   NodePort    10.43.197.115   <none>        8080:31000/TCP   83s

# 이렇게는 접속이 안되는 모습을 확인 할 수 있다.
# 서비스는 내부 ip address 이기 때문에 외부에서 접근하기 위해서 node port가 필요 한 것이다.
reallinux@project:~$ curl 10.43.197.115
^C

reallinux@project:~$ curl 10.43.197.115:8080
Hello World !

```

## pod 복제 Reaplica 5개로 유지하기

```bash
# 현재 실행중인 Pod 삭제하기
$ kubectl delete -f web-server-pod-svc.yaml

# yaml 파일 생성하기
$ vim web-server-replicaset.yaml
$ cat web-server-replicaset.yaml
apiVersion: apps/v1
kind: ReplicaSet
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
$ kubectl apply -f web-server-replicaset.yaml
# 참고 : yaml 파일을 통해서 Pod 삭제
$ kubectl delete -f web-server-replicaset.yaml

# Pod 와 ReplicaSet 확인
$ kubectl get pods,rs

# 각 노드(Master, Worker) 에 있는 Pod 확인하기
$ kubectl describe node | grep -e "Pods:\|Name:\|Roles:"
Name:               ubuntu
Roles:              control-plane,master
Non-terminated Pods:          (5 in total)
Name:               sub-node
Roles:              worker
Non-terminated Pods:          (4 in total)

# 실행중인 기본 Pod 와 web-server Pod 확인
$ kubectl describe node | grep -A 7 "Pods"
...
```

## 서비스 강제종료 테스트 및 상태 유지 확인

```bash
# Master 노드 기준으로 현재 Pod 확인하기
$ watch -n 0.1 kubectl get pods,rs -o wide

# Worker 노드 기준으로 Pod 프로세스 강제종료 실험
$ $ ps -ef | grep node
root      106117  104738  0 08:25 ?        00:00:00 /bin/sh -c node app.js
root      106118  104647  0 08:25 ?        00:00:00 /bin/sh -c node app.js
root      106137  104779  0 08:25 ?        00:00:00 /bin/sh -c node app.js
...

$ sudo kill -9 106117 106118 106137
```