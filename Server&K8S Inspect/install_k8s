# kubernetes-install-Guide
## 목차
0. [설치하기 전에](#00.-설치하기-전에,)
1. [MAC 주소 및 product_uuid](#1.-MAC-주소-및-product_uuid가-모든-노드에-대해-고유한지-확인)
2. [네트워크 어댑터](#2.-네트워크-어댑터-확인)
3. [iptables가 브리지된 트래픽](#3.-iptables가-브리지된-트래픽을-보게-하기)
4. [필수 포트 확인](#4.-필수-포트-확인)
5. [런타임 설치 (리눅스 ver.)](#5.-런타임-설치-(리눅스-ver.))
6. [설치하기](#6.-설치하기)

---
## 1장 Kubeadm - 클러스터 구성
<img src = "https://user-images.githubusercontent.com/67676024/123912558-27ceb480-d9b8-11eb-92cb-8302b68db3af.png" width="100" height="100"> 

- 쿠버네티스 클러스터 생성을 위한 모범 사례의 "빠른 경로"로 kubeadm init과 kubeadm join을 제공하도록 만들어진 도구
- 실행 가능한 최소 클러스터를 시작하고 실행하는 데 필요한 작업을 수행
- 설계 상, 시스템 프로비저닝이 아닌 부트스트랩(bootstrapping)만 다룬다.

### 00. 설치하기 전에,
- 호환되는 리눅스 머신. 쿠버네티스 프로젝트는 데비안 기반 배포판, 레드햇 기반 배포판, 그리고 패키지 매니저를 사용하지 않는 경우에 대한 일반적인 가이드를 제공한다.
- 2 GB 이상의 램을 장착한 머신. (이 보다 작으면 사용자의 앱을 위한 공간이 거의 남지 않음)
- 2 이상의 CPU
- 클러스터의 모든 머신에 걸친 전체 네트워크 연결. (공용 또는 사설 네트워크면 괜찮음)
- 모든 노드에 대해 고유한 호스트 이름, MAC 주소 및 product_uuid. 자세한 내용은 여기를 참고한다.
- 컴퓨터의 특정 포트들 개방. 자세한 내용은 여기를 참고한다.
- 스왑의 비활성화. kubelet이 제대로 작동하게 하려면 반드시 스왑을 사용하지 않도록 설정한다

### 1. MAC 주소 및 product_uuid가 모든 노드에 대해 고유한지 확인
- 사용자는 ip link 또는 ifconfig -a 명령을 사용하여 네트워크 인터페이스의 MAC 주소를 확인할 수 있다.
- product_uuid는 sudo cat /sys/class/dmi/id/product_uuid 명령을 사용하여 확인할 수 있다.
- 일부 가상 머신은 동일한 값을 가질 수 있지만 하드웨어 장치는 고유한 주소를 가질 가능성이 높다.
- 쿠버네티스는 이러한 값을 사용하여 클러스터의 노드를 고유하게 식별한다. 
- 이러한 값이 각 노드에 고유하지 않으면 설치 프로세스가 실패할 수 있다.

### 2. 네트워크 어댑터 확인
- 네트워크 어댑터가 두 개 이상이고, 쿠버네티스 컴포넌트가 디폴트 라우트(default route)에서 도달할 수 없는 경우, 쿠버네티스 클러스터 주소가 적절한 어댑터를 통해 이동하도록 IP 경로를 추가하는 것이 좋다.

### 3. iptables가 브리지된 트래픽을 보게 하기
- br_netfilter 모듈이 로드되었는지 확인한다. 
- lsmod | grep br_netfilter 를 실행하면 된다. 
- 명시적으로 로드하려면 sudo modprobe br_netfilter 를 실행한다.

리눅스 노드의 iptables가 브리지된 트래픽을 올바르게 보기 위한 요구 사항으로, sysctl 구성에서 net.bridge.bridge-nf-call-iptables 가 1로 설정되어 있는지 확인해야 한다. 

다음은 예시이다.
``` bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

### 4. 필수 포트 확인
#### **1) 컨트롤 플레인 노드**
|프로토콜|방향|포트 범위|목적|사용자|
|---|---|---|---|---|
|TCP|인바운드|6443*|쿠버네티스 API 서버|모두|
|TCP|인바운드|2379-2380|etcd 서버 클라이언트 API|kube-apiserver, etcd
|TCP|인바운드|10250|kubelet API|자체, 컨트롤 플레인
|TCP|인바운드|10251|kube-scheduler|자체
|TCP|인바운드|10252|kube-controller-manager|자체

#### **2) 워커 노드**
|프로토콜|방향|포트 범위|목적|사용자|
|---|---|---|---|---|
|TCP|인바운드|10250|kubelet API|자체, 컨트롤 플레인|
|TCP|인바운드|30000-32767|NodePort 서비스†|모두|

- † NodePort 서비스의 기본 포트 범위.
- *로 표시된 모든 포트 번호는 재정의할 수 있으므로, 사용자 지정 포트도 열려 있는지 확인해야 한다.
- etcd 포트가 컨트롤 플레인 노드에 포함되어 있지만, 외부 또는 사용자 지정 포트에서 자체 etcd 클러스터를 호스팅할 수도 있다.

### 5. 런타임 설치 (리눅스 ver.)
- 기본적으로, 쿠버네티스는 컨테이너 런타임 인터페이스(CRI)를 사용하여 사용자가 선택한 컨테이너 런타임과 인터페이스한다.
- 런타임을 지정하지 않으면, kubeadm은 잘 알려진 유닉스 도메인 소켓 목록을 검색하여 설치된 컨테이너 런타임을 자동으로 감지하려고 한다. 다음 표에는 컨테이너 런타임 및 관련 소켓 경로가 나열되어 있다.

    |런타임|유닉스 도메인 소켓 경로|
    |---|---|
    |도커|/var/run/dockershim.sock|
    |containerd|/run/containerd/containerd.sock|
    |CRI-O|/var/run/crio/crio.sock|

- 도커와 containerd가 모두 감지되면 도커가 우선시된다. 
- 이것이 필요한 이유는 도커 18.09에서 도커만 설치한 경우에도 containerd와 함께 제공되므로 둘 다 감지될 수 있기 때문이다.
- 다른 두 개 이상의 런타임이 감지되면, kubeadm은 오류와 함께 종료된다.
- kubelet은 빌트인 dockershim CRI 구현을 통해 도커와 통합된다.


### 6. 설치하기
모든 머신에 다음 패키지들을 설치한다.
- kubeadm: 클러스터를 부트스트랩하는 명령이다.
- kubelet: 클러스터의 모든 머신에서 실행되는 파드와 컨테이너 시작과 같은 작업을 수행하는 컴포넌트이다.
- kubectl: 클러스터와 통신하기 위한 커맨드 라인 유틸리티이다.

kubeadm은 kubelet 또는 kubectl 을 설치하거나 관리하지 않으므로, kubeadm이 설치하려는 쿠버네티스 컨트롤 플레인의 버전과 일치하는지 확인해야 한다. 그렇지 않으면, 예상치 못한 버그 동작으로 이어질 수 있는 버전 차이(skew)가 발생할 위험이 있다. 그러나, kubelet과 컨트롤 플레인 사이에 하나의 마이너 버전 차이가 지원되지만, kubelet 버전은 API 서버 버전 보다 높을 수 없다. 예를 들어, 1.7.0 버전의 kubelet은 1.8.0 API 서버와 완전히 호환되어야 하지만, 그 반대의 경우는 아니다.

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# permissive 모드로 SELinux 설정(효과적으로 비활성화)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```
