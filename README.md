# 공기팡 (PerformanceRecord)

뮤지컬, 연극 등 문화생활을 손쉽게 확인하고 나만의 관람 기록을 저장하는 앱.

---

## 📖 주요 기능

### 1. 공연 정보 탐색
- **박스오피스**: KOPIS API를 연동한 인기 공연 순위 제공.
- **공연 검색**: 공연 목록 조회 및 제목 기반 검색 기능.
- **상세 정보**: 공연 포스터, 줄거리, 출연진, 공연 기간 등 상세 정보 확인.
- **공연장 정보**: 공연장 위치 및 관련 정보 조회.

### 2. 나만의 기록 관리
- **관람 기록**: 관람한 공연에 대한 기록 생성, 수정, 삭제 관리.
- **사진 저장**: 공연 관련 사진(티켓, 캐스팅 보드 등) 첨부 기능.
- **상세 기록**: 관람일, 좌석, 별점, 메모 등 다양한 정보 기록.

### 3. 관심 공연
- **찜하기**: 관심 있는 공연을 '찜'하여 별도 보관 및 관리.
- **찜 목록**: 찜한 공연 목록을 통한 빠른 정보 접근.

---

## 🛠 기술적 특징

### 1. 아키텍처
- **Clean Architecture**: Presentation, Domain, Data 3-Layer 아키텍처를 적용하여 계층 간 역할 분리 및 관심사 분리(SoC) 원칙 준수.
- **MVVM**: Presentation 레이어 내 UI 로직과 비즈니스 로직 분리를 위해 MVVM(Model-View-ViewModel) 패턴 활용.
- **Repository Pattern**: Data 레이어에서 데이터 소스(Remote/Local)에 대한 접근을 추상화.

### 2. UI
- **Programmatic UI**: Storyboard 없이 코드로만 UI를 구성하여 유연성 및 재사용성 확보.
- **Compositional Layout**: `UICollectionViewCompositionalLayout`을 활용해 복잡하고 동적인 다중 섹션 레이아웃 구현.
- **Diffable DataSource**: `UICollectionViewDiffableDataSource`를 사용하여 데이터 변경에 따른 UI 업데이트를 안전하고 효율적으로 처리.
- **Wisp**: 인터랙티브한 View Controller 전환 애니메이션 구현을 위한 `Wisp` 라이브러리 사용.

### 3. 데이터 및 네트워킹
- **Realm**: 관람 기록, 찜 목록 등 사용자 데이터를 기기에 안전하게 저장하기 위한 로컬 데이터베이스로 채택.
- **Alamofire**: KOPIS API 통신을 위한 네트워킹 라이브러리로 사용.
- **Router Pattern**: API 엔드포인트를 체계적으로 관리하기 위한 Router 패턴 구현.
- **XMLCoder**: KOPIS API의 XML 응답을 Swift 객체로 디코딩하기 위해 활용.

### 4. 비동기 및 반응형 처리
- **Swift Concurrency**: `async/await`를 적극 활용하여 비동기 코드를 명확하고 간결하게 작성.
- **Actor**: `Repository` 구현에 `actor`를 적용하여 데이터베이스 접근 시 발생할 수 있는 Race Condition을 방지하고 데이터 무결성 보장.
- **RxSwift & RxCocoa**: ViewModel과 View 간의 데이터 바인딩, 비동기 이벤트 스트림 처리를 위해 사용.

### 5. 의존성 관리
- **Dependency Injection**: 객체 간 의존성 관리를 위해 직접 구현한 `DIContainer`와 `Assembler`를 활용. 이를 통해 모듈 간 결합도를 낮추고 테스트 용이성 증대.
