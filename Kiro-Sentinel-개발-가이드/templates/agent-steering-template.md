# Sentinel 개발 Agent Steering 템플릿
# 파일 위치: .kiro/steering/sentinel-context.md

---
inclusion: always
---

# Sentinel 정책 개발 컨텍스트

## 조직 표준

### 코딩 스타일
- **정책명**: kebab-case 사용 (예: `ec2-instance-type-validation`)
- **상수명**: UPPER_SNAKE_CASE 사용 (예: `ALLOWED_INSTANCE_TYPES`)
- **함수명**: snake_case 사용 (예: `validate_instance_type`)
- **변수명**: snake_case 사용 (예: `ec2_instances`)

### 네이밍 컨벤션
- **정책 파일**: `{service}-{resource}-{validation}.sentinel`
- **테스트 파일**: `{policy-name}.hcl`
- **모듈 파일**: `{module-name}.sentinel`

### 문서화 규칙
- 모든 정책 파일 상단에 설명 주석 필수
- 매개변수는 반드시 설명 주석 포함
- 복잡한 로직에는 인라인 주석 추가
- 한글 메시지 사용 (사용자 친화적)

## 필수 포함 요소

### 정책 파일 구조
```sentinel
# 정책 설명 및 메타데이터
# 필수 imports
# 매개변수 정의 (필요시)
# 상수 정의
# 헬퍼 함수들
# 메인 로직
# 출력 및 규칙
```

### 오류 처리
- 모든 외부 데이터 접근 시 null 체크 필수
- 예외 상황에 대한 명확한 메시지 제공
- 성능에 영향을 줄 수 있는 무한 루프 방지

### 테스트 요구사항
- 최소 3개의 테스트 케이스 (성공, 실패, 경계값)
- 실제 Terraform 상태 기반 모의 데이터 사용
- 매개변수가 있는 경우 다양한 값으로 테스트

## 보안 가이드라인

### 민감 정보 처리
- 하드코딩된 비밀번호, API 키 금지
- 환경 변수나 매개변수를 통한 설정값 전달
- 로그에 민감 정보 출력 금지

### 권한 검증
- 최소 권한 원칙 적용
- 리소스 접근 권한 사전 확인
- 관리자 권한 남용 방지

## 성능 최적화

### 효율적인 데이터 접근
- 필요한 리소스만 필터링하여 처리
- 중복 계산 방지를 위한 캐싱 활용
- 대용량 데이터 처리 시 배치 처리 고려

### 메모리 관리
- 대용량 컬렉션 처리 시 메모리 사용량 모니터링
- 불필요한 데이터 구조 생성 방지
- 가비지 컬렉션을 고려한 코드 작성

## 컴플라이언스 요구사항

### CIS 벤치마크 준수
- 모든 보안 정책은 CIS 벤치마크 기준 적용
- 정책 설명에 해당 CIS 컨트롤 번호 명시
- 정기적인 벤치마크 업데이트 반영

### SOC2 컴플라이언스
- 접근 제어 관련 정책 강화
- 감사 로그 생성 및 보관
- 데이터 암호화 요구사항 적용

## 개발 워크플로우

### Kiro Spec 활용
1. **Requirements**: 비즈니스 요구사항을 EARS 형식으로 작성
2. **Design**: 아키텍처 다이어그램과 함께 설계 문서 작성
3. **Tasks**: 구현 작업을 세분화하여 체크리스트로 관리

### Git 브랜치 전략
- `main`: 프로덕션 배포용 안정 브랜치
- `develop`: 개발 통합 브랜치
- `feature/*`: 기능 개발 브랜치
- `hotfix/*`: 긴급 수정 브랜치

### 코드 리뷰 체크리스트
- [ ] 정책 로직이 요구사항을 정확히 구현하는가?
- [ ] 테스트 케이스가 충분한가?
- [ ] 성능에 문제가 없는가?
- [ ] 보안 가이드라인을 준수하는가?
- [ ] 문서화가 적절한가?

## 도구 및 리소스

### 필수 도구
- **Sentinel CLI**: 로컬 테스트 및 검증
- **Terraform**: 모의 데이터 생성
- **Git**: 버전 관리
- **Kiro IDE**: 통합 개발 환경

### 유용한 리소스
- [Sentinel 공식 문서](https://docs.hashicorp.com/sentinel/)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS 보안 가이드](https://docs.aws.amazon.com/security/)
- [CIS 벤치마크](https://www.cisecurity.org/cis-benchmarks/)

## 예제 참조

#[[file:../templates/policy-template.sentinel]]
#[[file:../templates/test-template.hcl]]

---

이 컨텍스트는 모든 Sentinel 정책 개발 시 자동으로 적용됩니다.
추가 질문이나 가이드라인 수정이 필요한 경우 팀 리드에게 문의하세요.