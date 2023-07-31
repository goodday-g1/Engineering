안녕하세요!👩‍🏫  
Tech Interview 준비를 위해 질문으로 나올 만한 부분들을 정리합니다.  

---

# [목차]

## 0. [About_Engineer]
- 데이터 엔지니어로서의 생각하는 Career Path?
<br>

## 1. [코드리뷰]
### 1.1 [Flink-Kafka-Project]
- 코드 설명 : 전체 프로세스/주요 함수/의존성 등 정리 예정... by G1
  > 이 코드는 Flink와 Kafka, MySQL을 이용하여 데이터 파이프라인을 구축하는 프로그램입니다.   
  > Kafka 토픽에서 AppEventRecord 형식의 데이터를 읽어와 해당 데이터의 "gubun" 필드 값에 따라 고객, 계좌, 거래내역으로 분류하여 처리합니다. 처리된 데이터는 MySQL에 저장됩니다.
  
- Exactly-Once Semantics : 코드에서 사용된 KafkaSink의  Exactly-once Semantics 구성에 대해 설명하세요.
  > 코드에서 사용된 KafkaSink는 정확히 한 번의 전달 보장을 제공하는 설정으로 구성되어 있습니다. 이 설정을 통해 Flink 잡이 Kafka에 이벤트를 정확히 한 번만 전달하도록 보장합니다.
  - 왜 정확히 한 번의 전달 보장이 필요한가요?
  - 해당 기능이 코드에 어떻게 구현되어 있나요?

- Stateful Join: 코드에서 사용된 Stateful Join에 대해 설명하세요.  
  > Stateful Join은 데이터 처리 과정에서 상태를 유지하고 조인을 수행하는 방식입니다.  
  > 코드에서는 고객, 계좌, 거래내역 데이터를 처리하기 위해 Stateful Join을 사용하고 있습니다.  
  > 특정 키를 기준으로 데이터를 조인하기 위해 특정 상태를 유지하며 데이터를 처리합니다.
  - 어떤 상황에서 Stateful Join을 사용하나요?
  - Stateful Join을 구현하기 위해 어떤 데이터 처리 방식을 사용했나요?
  - Stateful Join 외에 또 어떤 Join 방식이 있을까요?
 
- 메모리 관리 : Stateful Join을 사용할 때, 공간복잡도를 최소화하기 위해 어떤 방법을 사용했는지 설명하세요.
  - Clear 작업이 언제 수행되나요?
  - Clear 작업이 왜 필요한가요? 꼭 필요한가요?

- 실행 설정 : 코드에서 사용된 Flink의 실행 환경 설정에 대해 설명하세요.
  - CheckPointing 주기, 병렬 처리 수, 그리고 다른 설정들이 왜 사용 되었는지 설명하세요.

- 코드에서 구현한 기능이 빅데이터 플랫폼에서 어떻게 활용될 수 있는지 설명하세요.

- 데이터 소스와 데이터 싱크 : 데이터소스(KafkaSource)와 데이터싱크(KafkaSink, MySQLSink)에 대해 설명하세요.
  - 각각의 역할과 설정에 대해 설명하세요.

- 성능과 확장성 : 위 코드의 성능과 확장성에 대해 어떻게 보장되는지 설명하세요.
  - 대용량 데이터를 처리하거나 처리 능력을 확장하기 위해 어떤 방법을 사용할 수 있는지 설명하세요

- 실패 처리와 재시작 : 코드에서 어떻게 실패를 처리하고, 재시작하는지 설명하세요.
  - CheckPointing과 재시작 시의 동작에 대해 설명하세요.

<br>

## 2. [Data PipeLine/WorkFlow]

### 2.1 [Flink]
- Flink의 특/장점?
- Flink의 다양한 Function 연산자들?
- Flink의 구조?
<br>

### 2.2 [Kafka]
<br>

### 2.3 [Spark]
<br>

### 2.4 [Zookeeper]
<br>

### 2.5 [Airflow]
<br>

### 2.6 [Jenkins]
<br>

---

## 3. [Cloud]
### 3.1 [Kubernetes]
<br>

### 3.2 [Docker]
<br>

### 3.3 [AWS]
<br>

### 3.4 [GCP]
<br>

<br>

---

## 4. [CI/CD]

