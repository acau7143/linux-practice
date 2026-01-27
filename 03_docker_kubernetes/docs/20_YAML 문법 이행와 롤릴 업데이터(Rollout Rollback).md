# YAML 문법 이행와 롤릴 업데이터(Rollout/Rollback)

```
yaml 파일은 apiversion, kind, metadata, spec는 기본적으로 들어간다. 
제일 중요한게 spec의 정보이다. 
```

```yaml
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
  type: NodePort # 지금 현재 서버로서의 port 번호를 외부에 노출 시켜서 접속을 가능하게 하는것
  ports:
    - port: 8080 # 서비스가 자체적으로 가지는 port 번호
      targetPort: 80 # container 의 port 번호
      protocol: TCP
      nodePort: 31000 # 노출되어 지는 포트 번호
  selector:
    app: webapp

```

## **쿠버네티스 기반 롤백 (Rollback / Rollout undo) 테스트**

```bash
# 롤백 진행하기
$ kubectl rollout status deploy/web-server-rs
$ kubectl rollout undo deploy/web-server-rs

# 또는
$ kubectl rollout undo deploy/web-server-rs --to-revision 2

# 버전 관리에 대한 히스토리 확인하기
$ kubectl rollout history deploy/web-server-rs

# Pod 와 ReplicaSet 와 Deployment 확인
$ watch -n 0.1 kubectl get pods,rs,deploy -o wide

# 롤아웃 진행과 CHANGE-CAUSE Annotation 기록 추가하기
$ kubectl set image deploy/web-server-rs web-server=reallinux/web-server:2 --record=true

# 버전 관리에 대한 히스토리 확인하기
$ kubectl rollout history deploy/web-server-rs

# Pod 와 ReplicaSet 와 Deployment 확인
$ watch -n 0.1 kubectl get pods,rs,deploy -o wide
```