# Sentinel 프로젝트 디렉터리 구조

## 권장 프로젝트 구조

```
my-sentinel-policies/
├── .kiro/                          # Kiro IDE 설정
│   ├── specs/                      # Spec 파일들
│   │   ├── ec2-security-policy/
│   │   │   ├── requirements.md
│   │   │   ├── design.md
│   │   │   └── tasks.md
│   │   └── s3-compliance-policy/
│   ├── steering/                   # Agent Steering 설정
│   │   ├── sentinel-context.md     # 전역 컨텍스트
│   │   ├── aws-specific.md         # AWS 특화 가이드라인
│   │   └── security-focused.md     # 보안 정책 전용
│   ├── hooks/                      # Agent Hooks 설정
│   │   ├── sentinel-development.yaml
│   │   └── deployment.yaml
│   └── settings/
│       └── mcp.json               # MCP 서버 설정
├── policies/                       # 정책 파일들
│   ├── security/                   # 보안 정책
│   │   ├── aws/
│   │   │   ├── ec2-instance-type.sentinel
│   │   │   ├── s3-bucket-encryption.sentinel
│   │   │   └── iam-password-policy.sentinel
│   │   ├── azure/
│   │   └── gcp/
│   ├── cost-optimization/          # 비용 최적화 정책
│   │   ├── resource-sizing.sentinel
│   │   ├── unused-resources.sentinel
│   │   └── tagging-enforcement.sentinel
│   ├── operational/                # 운영 정책
│   │   ├── backup-requirements.sentinel
│   │   ├── monitoring-setup.sentinel
│   │   └── logging-configuration.sentinel
│   └── custom/                     # 조직별 커스텀 정책
│       ├── company-naming-convention.sentinel
│       └── department-specific.sentinel
├── modules/                        # 재사용 가능한 모듈
│   ├── common/
│   │   ├── resource-filters.sentinel
│   │   ├── validation-helpers.sentinel
│   │   └── report-generators.sentinel
│   ├── aws/
│   │   ├── ec2-helpers.sentinel
│   │   ├── s3-helpers.sentinel
│   │   └── iam-helpers.sentinel
│   └── compliance/
│       ├── cis-benchmark.sentinel
│       ├── soc2-helpers.sentinel
│       └── pci-dss-helpers.sentinel
├── test/                           # 테스트 파일들
│   ├── policies/                   # 정책별 테스트
│   │   ├── security/
│   │   │   ├── ec2-instance-type.hcl
│   │   │   └── s3-bucket-encryption.hcl
│   │   ├── cost-optimization/
│   │   └── operational/
│   ├── mocks/                      # 모의 데이터
│   │   ├── tfplan/
│   │   │   ├── ec2-valid.json
│   │   │   ├── ec2-invalid.json
│   │   │   └── s3-scenarios.json
│   │   ├── tfconfig/
│   │   └── tfstate/
│   ├── fixtures/                   # 테스트용 Terraform 설정
│   │   ├── ec2-examples/
│   │   │   ├── valid-config.tf
│   │   │   └── invalid-config.tf
│   │   └── s3-examples/
│   └── integration/                # 통합 테스트
│       ├── full-stack-test.hcl
│       └── performance-test.hcl
├── docs/                           # 문서
│   ├── policies/                   # 정책별 문서
│   │   ├── security-policies.md
│   │   ├── cost-optimization.md
│   │   └── operational-policies.md
│   ├── development/                # 개발 가이드
│   │   ├── getting-started.md
│   │   ├── testing-guide.md
│   │   └── deployment-guide.md
│   ├── examples/                   # 예제 및 튜토리얼
│   │   ├── basic-policy-example.md
│   │   ├── advanced-patterns.md
│   │   └── troubleshooting.md
│   └── api/                        # API 문서
│       ├── modules-reference.md
│       └── functions-reference.md
├── scripts/                        # 유틸리티 스크립트
│   ├── generate-policy.sh          # 정책 템플릿 생성
│   ├── run-tests.sh               # 테스트 실행
│   ├── deploy.sh                  # 배포 스크립트
│   └── validate-all.sh            # 전체 검증
├── .github/                        # GitHub 설정
│   ├── workflows/                  # GitHub Actions
│   │   ├── test.yml
│   │   ├── deploy.yml
│   │   └── security-scan.yml
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── config/                         # 설정 파일들
│   ├── sentinel.hcl               # Sentinel 설정
│   ├── policy-sets.hcl            # 정책 세트 정의
│   └── environments/              # 환경별 설정
│       ├── development.hcl
│       ├── staging.hcl
│       └── production.hcl
├── templates/                      # 템플릿 파일들
│   ├── policy-template.sentinel
│   ├── test-template.hcl
│   ├── spec-template.md
│   └── documentation-template.md
├── .gitignore                     # Git 무시 파일
├── .sentinelignore               # Sentinel 무시 파일
├── README.md                      # 프로젝트 설명
├── CHANGELOG.md                   # 변경 이력
├── CONTRIBUTING.md                # 기여 가이드
└── LICENSE                        # 라이선스
```

## 디렉터리별 설명

### `.kiro/` - Kiro IDE 설정
- **specs/**: Spec 기반 개발을 위한 요구사항, 설계, 작업 문서
- **steering/**: Agent Steering 설정으로 개발 컨텍스트 제공
- **hooks/**: Agent Hooks 설정으로 자동화된 워크플로우 구성
- **settings/**: MCP 서버 등 IDE 설정

### `policies/` - 정책 파일들
- **카테고리별 분류**: security, cost-optimization, operational, custom
- **클라우드 제공자별 하위 분류**: aws, azure, gcp
- **명확한 네이밍**: `{service}-{resource}-{validation}.sentinel`

### `modules/` - 재사용 가능한 모듈
- **common/**: 모든 정책에서 사용할 수 있는 공통 함수
- **클라우드별**: 각 클라우드 제공자별 헬퍼 함수
- **컴플라이언스별**: 특정 컴플라이언스 표준을 위한 모듈

### `test/` - 테스트 관련
- **policies/**: 각 정책에 대응하는 테스트 파일
- **mocks/**: 테스트용 모의 데이터
- **fixtures/**: 테스트용 Terraform 설정
- **integration/**: 통합 테스트 및 성능 테스트

### `docs/` - 문서
- **정책별 문서**: 각 정책의 사용법과 예제
- **개발 가이드**: 개발자를 위한 가이드
- **예제**: 실제 사용 사례와 패턴

### `scripts/` - 자동화 스크립트
- **개발 도구**: 정책 생성, 테스트 실행 등
- **배포 도구**: 자동 배포 및 검증

## 파일 네이밍 규칙

### 정책 파일
```
{cloud-provider}-{service}-{resource}-{validation-type}.sentinel

예시:
- aws-ec2-instance-type-validation.sentinel
- azure-vm-size-restriction.sentinel
- gcp-compute-disk-encryption.sentinel
```

### 테스트 파일
```
{policy-name}.hcl

예시:
- aws-ec2-instance-type-validation.hcl
- azure-vm-size-restriction.hcl
```

### 모듈 파일
```
{category}-{functionality}.sentinel

예시:
- aws-resource-helpers.sentinel
- validation-common-functions.sentinel
- cis-benchmark-utilities.sentinel
```

## 환경별 구성

### 개발 환경
```
config/environments/development.hcl
- 느슨한 정책 적용
- 상세한 디버그 로그
- 빠른 피드백을 위한 최적화
```

### 스테이징 환경
```
config/environments/staging.hcl
- 프로덕션과 유사한 정책 적용
- 성능 테스트 및 부하 테스트
- 통합 테스트 실행
```

### 프로덕션 환경
```
config/environments/production.hcl
- 엄격한 정책 적용
- 최소한의 로그
- 최적화된 성능 설정
```

이 구조를 따르면 체계적이고 확장 가능한 Sentinel 정책 프로젝트를 구축할 수 있습니다.