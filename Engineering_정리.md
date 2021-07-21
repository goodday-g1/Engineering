[목차]
1. [리눅스](#ⅰ-리눅스)  
  1.1 [리눅스 환경 확인](#1-리눅스-환경-확인)  
  1.2 [스케줄링](#2-배치-스케쥴링)  
  1.3 [PID 변수 찾기](#3-pid-변수-찾기)   
  1.4 [테스트 파일 만들기](#4-테스트-파일-만들기)  
  1.5 [Jupyter Notebook](#5-jupyter-notebook-설치하기)  
2. [하이퍼데이터](#hyperdata-설치)
3. [VI 편집기](#ⅲ-vi-편집기)
4. [DOCKER](#ⅳ-docker)
5. [쿠버네티스](#ⅴ-쿠버네티스)  
   5.1 [K8S 기본](#1.-기본)
   5.2 [Rook-Ceph](#2.-Rook-Ceph)
6. [네트워크](#ⅵ-network)
7. [기타](#기타)

---

# **Ⅰ. 리눅스**
## **1. 리눅스 환경 확인**
### 00. **설치확인서** 작성 시, 필요한 정보
1. OS 및 OS Bit : 
    - uname -a
    - cat /etc/*release*  
        
2. Host Name :
   - uname -n  

3. NCPU_Result :  
  3.1  CPU 및 CPU 갯수
   - CPU  정보 :  
      ```bash
      cat /proc/cpuinfo
      ```
   - CPU 갯수 : 
      ```bash
      grep "physical id" /proc/cpuinfo | sort -u | wc -l  
      ```

   3.2  코어 수, 쓰레드 수  
   - 코어 수 : 
      ```bash
      grep -c processor /proc/cpuinfo
      ```
   - 쓰레드 수 : 
      ```bash
      cat /proc/$(pidof mysqld)/status | grep ^Threads
      ```
1.  MEMORY : 
      ```bash
      cat /proc/meminfo | grep MemTotal
      ```
    - 1024 나누기 한 다음 1000으로 또 나누기
    - kB → GB : 1e+6(1,000,000)으로 나누기
2.  DISK : 
      ```bash
      lsblk -d -o name,rota  # HDD는 1, SSD는 0
      ```
    - lsblk -d
    - fdisk -l : 각각 용량 확인

### 01. **CPU** 관련 사항 확인 (세부)
~~~ bash
#cpu info 정리
cat /proc/cpuinfo
cat /proc/cpuinfo | more
dmesg | grep cpu

# CPU 비트 확인(x86, x64)
 arch

#cpu 물리 갯수
grep "physical id" /proc/cpuinfo | sort -u | wc -l

# cpu 코어 갯수
grep -c processor /proc/cpuinfo

#cpu 코어 정보
grep "cpu cores" /proc/cpuinfo | tail -1

#메모리 정보
cat /proc/meminfo | grep MemTotal
free

# 디스크 공간 통계 보기
df -h
 
# DISK 정보 확인
 lsblk -d -o name,rota  # HDD는 1, SSD는 0
 cat /proc/scsi/scs             -- scsi
 cat /proc/ide/hda/model    -- hda
 cat /proc/mdstat                -- raid
 /proc/ide/                         -- 아래에는 하드가 몇개인지
 /proc/ide/hda/                  -- 아래에는 그 하드에 대한 여러 정보

# DISK 용량 확인
 df -h              -- 디스크 파티션, 용량 정보 → 나오는 정보 : Size  Used Avail Use% Mounted on
 fdisk -l           -- 하드디스크 확인
 du -sk             -- 현재 폴더의 사용량(kb)
 du -sk /home       -- /home 폴더의 사용량(kb)

# NETWORK 정보 확인
 cat /proc/net/netlink
 ifconfig -a

# 리눅스 버전 확인
 uname -a
 uname -r
 cat /proc/version
 rpm -qa *-release
 cat /etc/*-release 

# 리눅스 배포본 확인
 cat /etc/hedhat-release
  Red Hat Enterprise Linux Server release 4.7 (Santiago)

# 디스크 들에 대해서 총량, 할당량, 사용량
kubectl exec -it -n rook-ceph  $(kubectl get po -n rook-ceph |grep tools | awk '{print $1}') -- /usr/bin/ceph osd status

# kubernetes node 별 cpu 혹은 memory 확인
kubectl describe nodes | grep cpu
kubectl describe nodes | grep mem

~~~

### 02. **사용률** 확인
- 참고 : https://zetawiki.com/wiki/%EB%A6%AC%EB%88%85%EC%8A%A4_CPU_%EC%82%AC%EC%9A%A9%EB%A5%A0_%ED%99%95%EC%9D%B8

1) 리눅스 CPU 사용률 확인
  - 방법 1: mpstat
      ~~~bash
      mpstat
      mpstat | tail -1 | awk '{print 100-$NF}'
      ~~~
  - 방법 2: top ★
      ~~~ bash
      top -b -n1 | grep -Po '[0-9.]+ id'
      top -b -n1 | grep -Po '[0-9.]+ id' | awk '{print 100-$1}'
      ~~~  


---
## **2. 배치 스케쥴링**
### **01. crontab**
- X.sh 파일 설정
~~~ shell
$ vi X.sh
  # 10 0 * * * /root/X.sh  #-> 매일 오전 00시 10분에 /root/에 있는 X.sh 파일 돌리기
  # 초 분 시 일 월 요일 
$ crontab -e # 크론 리스트를 보기, 하단에 원하는 스케쥴링 작업 걸기
~~~
## **3. PID 변수 찾기**
```bash
ps -ef | grep Server | grep -v 'grep' | awk '{print $2}' #=>  'Server'라는 프로그램 명이 들어간 PID 표시
```
---
---
## **4. 테스트 파일 만들기**
- 윈도우는 fsutil, 리눅스는 dd 라는 명령어를 이용하여 생성할 수 있습니다.
- 주의 : fsutil의 경우 동일한 파일명이나 폴더가 존재할 경우 에러 발생, dd 는 덮어쓰기
### 윈도우 (fsutil)
- fsutil
``` bash
 fsutil file createnew [filename] [filesize]
    ex) fsutil file createnew test 102400
          #--> test 란 이름으로 1MB 의 파일이 생성된다.
```

### 리눅스 (dd)
- dd
``` bash
  dd if=/dev/zero of=[위치 및 파일명] bs=[filesize] count=[반복횟수]
    ex) dd if=/dev/zero of=/root/test.txt bs=100M count=1
         #--> text.txt 란 이름으로 100MB 의 파일이 생성된다.
         #count가 2일 경우 200MB 가 생성된다.
```
## **5. Jupyter Notebook 설치하기**
### **01. 주피터 노트북을 설치하기 위한 가상환경(아나콘다 설치)**
- https://www.anaconda.com/products/individual#Downloads
- Linux 라인 중 가장 위 Python 3.8 > 64-Bit(x86) Installer (544MB) 다운로드
- xftp를 이용해서, 설치하고자 하는 서버에 옮겨주기

### **02. 다운로드 완료 후 터미널에서 설치 진행**
```bash
[root@hd-hc06 jupyter] # bash Anaconda3-2021.05-Linux-x86_64.sh
   > enter # 라이센스 확인(쭈우우욱 읽기) 
   > yes #정책 동의 
   > init 도 yes
```
```bash
[root@hd-hc06 jupyter]# source ~/.bashrc
```
```bash
(base) [root@hd-hc06 jupyter]# conda install jupyter notebook
Collecting package metadata (current_repodata.json): done
Solving environment: done

## Package Plan ##
  environment location: /root/anaconda3
  added / updated specs:
    - jupyter
    - notebook
  The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    conda-4.10.3               |   py38h06a4308_0         2.9 MB
    ------------------------------------------------------------
                                           Total:         2.9 MB

  The following packages will be UPDATED:
  conda                                4.10.1-py38h06a4308_1 --> 4.10.3-py38h06a4308_0

Proceed ([y]/n)? y

Downloading and Extracting Packages
conda-4.10.3         | 2.9 MB    | ############################################################################### | 100%
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
```
```bash
(base) [root@hd-hc06 jupyter]# pip install jupyter-analysis-extension
```

> #### 여기서 아래와 같은 에러가 발생
> ```bash
> ERROR: pips dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
> spyder 4.2.5 requires pyqt5<5.13, which is not installed.
> spyder 4.2.5 requires pyqtwebengine<5.13, which is not installed.
> conda-repo-cli 1.0.4 requires pathlib, which is not installed.
> ```

> #### 해결방안
> ```bash
> (base) [root@hd-hc06 jupyter]# pip install --upgrade pip
> Requirement already satisfied: pip in /root/anaconda3/lib/python3.8/site-packages (21.1.3)
> WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
> ```
 
> ```bash
> (base) [root@hd-hc06 jupyter]# pip --version
> pip 21.1.3 from /root/anaconda3/lib/python3.8/site-packages/pip (python 3.8)
> ```

> ```bash
> (base) [root@hd-hc06 jupyter]# pip install jupyter-analysis-extension
> ```

### **03. 설치 완료 후 nbextension enable**
```bash
(base) [root@hd-hc06 jupyter]# jupyter nbextension enable --py --sys-prefix widgetsnbextension
Enabling notebook extension jupyter-js-widgets/extension...
      - Validating: OK
```
```bash
(base) [root@hd-hc06 jupyter]# jupyter nbextension enable --py --sys-prefix qgrid
Enabling notebook extension qgrid/extension...
      - Validating: OK
```
### **04. Jupyter Notebook 웹으로 띄우기**
#### **방법 1. 띄울 때, 명령어로**
- jupyter notebook --ip={IP주소} --port={port} --allow-root
- 출력되는 URL 주소를 포트 다음 토큰 값까지 복사해서 웹에 넣기
- 만약 ip와 port만 입력하고 접근할 때, 토큰 값을 따로 입력해줘야한다.
```bash
(base) [root@hd-hc06 jupyter]# jupyter notebook --ip=192.168.210.211 --port=8888 --allow-root
[W 2021-07-19 12:33:03.401 LabApp] 'ip' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[W 2021-07-19 12:33:03.401 LabApp] 'port' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[W 2021-07-19 12:33:03.401 LabApp] 'allow_root' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[W 2021-07-19 12:33:03.401 LabApp] 'allow_root' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
[I 2021-07-19 12:33:03.407 LabApp] JupyterLab extension loaded from /root/anaconda3/lib/python3.8/site-packages/jupyterlab
[I 2021-07-19 12:33:03.407 LabApp] JupyterLab application directory is /root/anaconda3/share/jupyter/lab
[I 12:33:03.410 NotebookApp] Serving notebooks from local directory: /data/g1/jupyter
[I 12:33:03.410 NotebookApp] Jupyter Notebook 6.3.0 is running at:
[I 12:33:03.410 NotebookApp] http://192.168.210.211:8888/?token=2e7a233dbe0d658f33bee699ef210fac66cfaca79bd75478
[I 12:33:03.410 NotebookApp]  or http://127.0.0.1:8888/?token=2e7a233dbe0d658f33bee699ef210fac66cfaca79bd75478
[I 12:33:03.410 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[W 12:33:03.413 NotebookApp] No web browser found: could not locate runnable browser.
[C 12:33:03.413 NotebookApp]

    To access the notebook, open this file in a browser:
        file:///root/.local/share/jupyter/runtime/nbserver-3989-open.html
    Or copy and paste one of these URLs:
        http://192.168.210.211:8888/?token=2e7a233dbe0d658f33bee699ef210fac66cfaca79bd75478
     or http://127.0.0.1:8888/?token=2e7a233dbe0d658f33bee699ef210fac66cfaca79bd75478
[I 12:33:13.385 NotebookApp] 302 GET /?token=2e7a233dbe0d658f33bee699ef210fac66cfaca79bd75478 (192.168.173.57) 0.390000ms
[I 12:33:18.755 NotebookApp] Creating new notebook in
[I 12:33:18.778 NotebookApp] Writing notebook-signing key to /root/.local/share/jupyter/notebook_secret
[I 12:33:19.863 NotebookApp] Kernel started: 63e03fa0-bf86-4cd5-b311-c77e202e16c4, name: python3
```
#### **방법 2. 설정 파일을 수정해서**
- jupyter notebook 비밀번호 생성
  ```bash
  (base) [root@hd-hc06 jupyter]# ipython
  Python 3.8.8 (default, Apr 13 2021, 19:58:26)
  Type 'copyright', 'credits' or 'license' for more information
  IPython 7.25.0 -- An enhanced Interactive Python. Type '?' for help.
  
  In [1]: from notebook.auth import passwd
  In [2]: passwd()
  Enter password: {비밀번호 입력}
  Verify password: {비밀번호 입력}
  Out[2]: #복사하여 config 파일에 작성 예정
  'argon2:$argon2id$v=19$m=10240,t=10,p=8$7Odgr+IhHbmy+GVPTJIv8Q$0KSmIlw2ZyHU6Yn93bc/og'
  In [3]: exit
  ```
- config 파일 수정
    ```bash
   (base) [root@hd-hc06 jupyter]# vi /root/.jupyter/jupyter_notebook_config.py
   ```
   
   - 수정 내용
   ```python
   c = get_config()

   c.NotebookApp.allow_origin = '*'
   c.NotebookApp.notebook_dir = '../'
   c.NotebookApp.ip = '192.168.210.211'
   c.NotebookApp.port = 8888
   c.NotebookApp.password = u'argon2:$argon2id$v=19$m=10240,t=10,p=8$7Odgr+IhHbmy+GVPTJIv8Q$0KSmIlw2ZyHU6Yn93bc/og'
   c.NotebookApp.open_browser = False
   
   # Configuration file for jupyter-notebook.
   ```


- jupyter notebook 실행
   ```bash
   (base) [root@hd-hc06 jupyter]# cd /root/.jupyter/

   (base) [root@hd-hc06 .jupyter]# jupyter notebook --config jupyter_notebook_config.py --allow-root
   [W 2021-07-19 13:44:53.377 LabApp] 'config_file' was found in both NotebookApp and ServerApp. This is likely a recent change. This config will only be set in NotebookApp. Please check if you should also config these traits in ServerApp for your purpose.
   [W 2021-07-19 13:44:53.377 LabApp] 'allow_root' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [W 2021-07-19 13:44:53.377 LabApp] 'allow_origin' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [W 2021-07-19 13:44:53.377 LabApp] 'notebook_dir' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [W 2021-07-19 13:44:53.377 LabApp] 'ip' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [W 2021-07-19 13:44:53.377 LabApp] 'port' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [W 2021-07-19 13:44:53.377 LabApp] 'password' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [W 2021-07-19 13:44:53.377 LabApp] 'password' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [W 2021-07-19 13:44:53.377 LabApp] 'password' has moved from NotebookApp to ServerApp. This config will be passed to ServerApp. Be sure to update your config before our next release.
   [I 2021-07-19 13:44:53.383 LabApp] JupyterLab extension loaded from /root/anaconda3/lib/python3.8/site-packages/jupyterlab
   [I 2021-07-19 13:44:53.383 LabApp] JupyterLab application directory is /root/anaconda3/share/jupyter/lab
   [I 13:44:53.386 NotebookApp] Serving notebooks from local directory: /root
   [I 13:44:53.386 NotebookApp] Jupyter Notebook 6.3.0 is running at:
   [I 13:44:53.386 NotebookApp] http://192.168.210.211:8888/
   ```
   > #### 에러 발생
   > ```bash
   > [C 13:44:25.642 NotebookApp] Bad config encountered during initialization: The 'port' trait of a NotebookApp instance expected an int, not the str '8888'.
   > ```

   >#### 해결방안  
   > port 에 string 타입의 데이터가 있다는 뜻인데,  
   > config 파일 내 port를 지정할 때, ' ' 표시를 하지 말아야한다.

---
---

# **Ⅱ. HyperData**
## alias
```bash
alias dasboot='startDomainAdminServer -u jeus -p jeus'
alias dasdown='stopServer -host localhost:9736 -u jeus -p jeus'

alias hdstart='startManagedServer -server hyperdata -u jeus -p jeus'
alias hdstop='stopServer -host localhost:19736 -u jeus -p jeus'

alias pastart='startManagedServer -server ProAuth -u jeus -p jeus'
alias pastop='stopServer -host localhost:29736 -u jeus -p jeus'
```
## Tibero연동

- HyperData 파드 내부 ->  /db/input/
- -> bad확장명의 파일 : 날짜 왼쪽 컬럼에 숫자가 있으면 (0제외) 문제가 있다.  
- 원천 데이터(Schema 등) 에서 들어가지 못한 데이터가 bad로 남음

---
---
# **Ⅲ. VI 편집기**

## **1. 기본 단축키**
- G : 바닥으로 가기
- gg : 맨 위로 가기

---
---
# **Ⅳ. DOCKER**
## **1. docker Registry 설정**
### 1. 도커 레파지토리의 아래와 같은 디렉토리로 이동한다.
cd /data/bips-repo/docker/registry/v2/repositories/hdml/mllab_notebook/_manifests/tags

```bash
[root@k8s-master01 tags]# ls -al
합계 24
drwxr-xr-x. 6 root root 4096  1월 28 21:57 .
drwxr-xr-x. 4 root root 4096  1월 25 13:56 ..
drwxr-xr-x. 4 root root 4096  1월 27 18:00 tf_v1.14.0
drwxr-xr-x. 4 root root 4096  1월 28 21:56 tf_v1.15.2
drwxr-xr-x. 4 root root 4096  1월 25 13:56 tf_v2.1.0
drwxr-xr-x. 4 root root 4096  1월 28 21:57 torch_v1.6.0
```

## 2. 지우고자 하는 태그의 디렉토리를 지운다.
```bash
rm -rf ./tf_v1.15.2
```

## 3. docker registry 컨테이너 아이디를 찾는다. 명령어를 수행한다.
```bash
docker ps |grep registry

#> 찾은 ID 값으로 registry garbage-collect 명령어를 수행한다.
docker exec -it 6eaa4b3a69cb registry garbage-collect /etc/docker/registry/config.yml


#> 간단히 한줄로 요약하면 아래와 같은 명령어로 수행 가능하다.
docker exec -it $(docker ps |grep registry |awk '{print $1}') registry garbage-collect /etc/docker/registry/config.yml
```
---
---
# **Ⅴ. 쿠버네티스**
## **1. 기본**
### **1. pod 강제삭제**

- 기본 : kubectl delete pod [파드명]
- 강제 삭제 : --grace-period=0 --force
  
### **2. kubectl source 추가**
```bash
vi 05.hd_yaml
> source <(kubectl completion bash)
> complete -F __start_kubectl k

kubectl completion bash > /etc/bash_completion.d/kubectl
. .bashrc

kubectl g-bash: _get_comp_words_by_ref
```

### **3.curl**
3.1. 이미지 정보 보기
```bash
curl -X GET {IP주소}/v2/_catalog 
ex. $ curl -X GET http://localhost:5000/v2/_catalog
```
3.2. tag list 보기
```bash
# 출력 {"repositories":["hello-world"]}

# 태그 정보 확인하기
$ curl -X GET http://localhost:5000/v2/hello-world/tags/list
# 출력 {"name":"hello-world","tags":["latest"]}

X GET 192.168.158.62:5000/v2/hyperdata8.3_hd_v8.3.4hotpatch/tags/list
{"name":"hyperdata8.3_hd_v8.3.4hotpatch","tags":["20210126_v1","20210127_v1","20210203_v1","20210203_v2","20210203_v3","20210208_v1","20210215_v1","20210215_v2","20210217_v1"]}
```

## **2. Rook-Ceph**
### **2.1 Rook-Ceph-Operator 재기동**
1. About. Rook-Ceph
  - Rook-Ceph-Operator : Rook-Ceph 컨트롤타워
  - krm Rook-Ceph-Operator -> Rook-Ceph-Detect가 생겼다가 지워진 후, 각 Pod들 재기동
  - OSD-Prepare : 각 Disk Mounted 된 노드 별로(물리적 HDD를 물리는 갯수 만큼), Pod가 뜨고 다시 Comleted 상태로 변환   
     (에러 당시에는, 계속 Concreating 상태) -> OSD 5는 Disk가 5개라는 의미
  - Plugin들은 정보를 가져와서 진행
  - ceph : N/W 스토리지를 만드는 아이 (Storage는 Block Storage / File Storage 등으로 유형을 정할 수 있음)
  - mon : monitoring daemon
  - myfs : File System Storage를 만들기 위한 아이  
    File Storage를 만드려면 무조건 하나 이상 있어야 함
    - cf) ceph 관련 공식 문서를 확인하면, 리소스 설정 가이드가 있음  
    ```bash
    kubectl exec -it -n rook-ceph  $(kubectl get po -n rook-ceph |grep tools | awk '{print $1}') -- /usr/bin/ceph -s #확인 가능
    ```

2. 해결방안
   - rook-ceph-Operator 재기동
    ```bash 
    kubectl remove rook-ceph-operator
    ```
---
---
# **Ⅵ. Network**
## **0. NAS & DAS & SAN**
- 이론적인 내용  
   참조:   
   https://www.stevenjlee.net/2020/05/24/이해하기-스토리지storyage-의-종류das-nas-san-와-개념/
   https://www.ciokorea.com/tags/1023/NAS/37369  
   https://tech.gluesys.com/blog/2019/12/02/storage_1_intro.html  
   https://ensxoddl.tistory.com/286
   https://louie0.tistory.com/108

## 1. NAS & SAN & DAS 란?
- DAS - 일반적인 storage(Direct Attached Storage)
- NAS           - protocol 에 따른 분류
    - NFS         - 리눅스
    - SMB/CIFS    - 윈도우
    - FTP
    - HTTP
    - AFP

- SAN   -   protocol에 따른 분류
    - FC    &nbsp;&nbsp;      ┐ 물리적
    - FCIP      ┘ 물리적+네트워크
    iSCSI      
    iSER

- FCIP와 iFCP와 iSCSI 등의 개념을 잘 설명: https://dreamlog.tistory.com/565      

## 2. NAS vs SAN
- NAS는 File 단위 I/O
- SAN은 Block 단위 I/O
- SAN과 NAS 공통점: 모두 네트워크 기반 스토리지 솔루션
                    SAN과 NAS 모두 네트워크를 이용하여 연결
- SAN NAS 차이점
  - NAS
    표준 이더넷 연결을 통해 네트워크 연결
    file 단위로 데이터 저장(접속?)
    OS 입장에서 NAS는 파일 서버
  - SAN
    파이버 채널 연결 이용(FC)
    Block 수준 데이터 저장
    OS 입장에서 SAN은 일반 디스크
      
- 전용의 고속 네트워크로 구성 - 스토리지 트래픽을 다른 LAN과 분리해 가용성 및 성능 확보

SAN은 서로 연결된 호스트와 스위치, 스토리지 기기로 구성된다.
SAN은 별도의 스위치가 필요함(((TAS도 switch 따로 구성 필요)
SAN 종류
   일반적으로 파이버 채널 사용                     ---   FC
   FCoE(Fibre Channel over Ethernet)도 사용가능   ---   FCIP
   주로 SMB에서 iSCSI 이용해 연결
   고성능 컴퓨팅 환경에서는 InfiniBand 이용해 연결
   

속도 때문에 Database는 SAN을 추천

NAS는 파일공유, 소규모 가상화 환경(개인pc 등), 아카이브
SAN은 Database, 대규모 가상화 환경, 영상작업

SAN
storage1 + storage2 + ... = Logical Volume
LUN(Logical Unit Number) = Logical Volume안에서 Disk들이 받는 고유번호, LUN을 통해 Disk 접속 및 관리



iSCSI 활용 (target, initiator)
   참조:
   https://www.joinc.co.kr/w/Site/cloud/Qemu/iSCSI


iSCSI Target = iSCSI 볼륨을 제공하는 시스템 (예를 들면 iSCSI Storage 장비)
iSCSI Initiator = Target을 Mount해서 사용하는 장비 (서버, Linux 등..)

Target을 관리하기 위해서 앱 설치
$ yum install scsi-target-utils (root권한으로)

Target의 데몬 실행
$ /etc/init.d/tgtd

데몬이 부팅 때마다 동작하도록 등록해줌
$ ckconfig --level 35 tgtd on

iSCSI Target 이름 지정
$

iSCSI Target 지정된 이름 확인
$ tgtadm --lld iscsi --op show --mode target

설정한 iSCSI Target 이름에 시스템의 볼륨을 등록
$ tgtadm --lld iscsi --op new --mode logicalunit --tid 1 --lun 1 -b /dev/sdb1

...(추가적인 내용은 참조 블로그 확인)

initiator 설치 및 설정
...(추가적인 내용은 참조 블로그 확인)


CenotOS iscsi 구성방법:
https://blog.boxcorea.com/wp/archives/1811

fdisk
https://lopicit.tistory.com/150

---

# DB

## TIBERO
### 접속
 ~~~bash
 tbsql sys/tibero
 ~~~

### 세션 확인
  ~~~sql
  SELECT * FROM v$SESSION
  ~~~
---
---
# **기타**
## 1. mail?
- mail 이 왔다? 명령어를 치면, you have a new mail이라는 알람이 뜸
```bash
cat /var/spool/mail/root
```
- 내용 : 
~~~bash
From root@hc-hd01.localdomain  Fri Feb 19 00:00:01 2021
Return-Path: <root@hc-hd01.localdomain>
X-Original-To: root
Delivered-To: root@hc-hd01.localdomain
Received: by hc-hd01.localdomain (Postfix, from userid 0)
	id 35EAA124AB941; Fri, 19 Feb 2021 00:00:01 +0900 (KST)
From: "(Cron Daemon)" <root@hc-hd01.localdomain>
To: root@hc-hd01.localdomain
Subject: Cron <root@hc-hd01> ntpdate time.bora.net
Content-Type: text/plain; charset=UTF-8
Auto-Submitted: auto-generated
Precedence: bulk
X-Cron-Env: <XDG_SESSION_ID=792>
X-Cron-Env: <XDG_RUNTIME_DIR=/run/user/0>
X-Cron-Env: <LANG=ko_KR.UTF-8>
X-Cron-Env: <SHELL=/bin/sh>
X-Cron-Env: <HOME=/root>
X-Cron-Env: <PATH=/usr/bin:/bin>
X-Cron-Env: <LOGNAME=root>
X-Cron-Env: <USER=root>
Message-Id: <20210218150001.35EAA124AB941@hc-hd01.localdomain>
Date: Fri, 19 Feb 2021 00:00:01 +0900 (KST)

/bin/sh: ntpdate: command not found

[root@hc-hd01 v8.3.4_20210128]# /var/spool/mail/root > mail.txt
-bash: /var/spool/mail/root: 허가 거부

[root@hc-hd01 v8.3.4_20210128]# sudo /var/spool/mail/root > mail.txt
sudo: /var/spool/mail/root: 명령이 없습니다

[root@hc-hd01 v8.3.4_20210128]# cd /var/spool/mail/
[root@hc-hd01 mail]# ll
합계 1248
drwxrwxr-x.  2 root mail      18  2월 19 00:00 ./
drwxr-xr-x. 11 root root     133  3월 19  2020 ../
-rw-------.  1 root mail 1275472  2월 19 00:00 root

[root@hc-hd01 mail]# chmod 755 root 
[root@hc-hd01 mail]# sudo /var/spool/mail/root > mail.txt
/var/spool/mail/root: line 1: From: command not found
/var/spool/mail/root: line 2: syntax error near unexpected token 'newline'
/var/spool/mail/root: line 2: 'Return-Path: <user@localhost.localdomain> '
~~~
## 2. HyperData - Alias
### ALIAS
  ~~~ bash
  alias dasboot='startDomainAdminServer -u jeus -p jeus'
  alias dasdown='stopServer -host localhost:9736 -u jeus -p jeus'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias grep='grep --color=auto'
  alias hdstart='startManagedServer -server hyperdata -u jeus -p jeus'
  alias hdstop='stopServer -host localhost:19736 -u jeus -p jeus'
  alias ja='jeusadmin -u jeus -p jeus'
  alias jadmin='jeusadmin -u jeus -p jeus'
  alias l.='ls -d .* --color=auto'
  alias ll='ls -l --color=auto'
  alias ls='ls --color=auto'
  alias pastart='startManagedServer -server ProAuth -u jeus -p jeus'
  alias pastop='stopServer -host localhost:29736 -u jeus -p jeus'
  alias polog='tail -100f /home/hyperdata/proobject8/logs/ProObject.log'
  alias slog='tail -100f /home/hyperdata/tibero6/instance/tibero/log/slog/sys.log'
  alias tbbin='cd $TB_HOME/bin'
  alias tbcfg='cd $TB_HOME/config'
  alias tbcfgv='vi $TB_HOME/config/$TB_SID.tip'
  alias tbcli='cd ${TB_HOME}/client/config'
  alias tbcliv='vi ${TB_HOME}/client/config/tbdsn.tbr'
  alias tbhome='cd $TB_HOME'
  alias tbi='cd ~/tbinary'
  alias tblog='cd $TB_HOME/instance/$TB_SID/log'
  alias tm='sh ~/tbinary/monitor/monitor'
  alias vi='vim'
  alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
  ~~~
