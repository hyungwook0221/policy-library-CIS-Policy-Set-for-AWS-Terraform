# AWS CIS Foundations Benchmark Sentinel 정책 사용 가이드

## 개요

이 저장소는 HashiCorp와 AWS가 공동 개발한 Terraform의 Sentinel 프레임워크를 사용하여 AWS CIS Foundations Benchmark v1.2, v1.4, v3.0을 준수하는 사전 작성된 정책들을 제공합니다. 이러한 정책들은 AWS 리소스가 업계 보안 표준을 충족하도록 도와주는 즉시 사용 가능한 컴플라이언스 검사 도구입니다.

## 주요 특징

- **사전 작성된 정책**: 개발 시간을 단축하고 리소스를 절약할 수 있는 전문가가 작성한 정책
- **CIS 표준 준수**: CIS AWS Foundations Benchmark 표준에 따른 보안 모범 사례 적용
- **HCP Terraform 통합**: Terraform Cloud 및 Terraform Enterprise와 완벽 호환
- **모듈화된 구조**: 유지보수가 용이한 모듈식 설계

## 지원되는 AWS 서비스 및 정책

### CloudTrail 정책
- CloudTrail S3 버킷 액세스 로깅 활성화
- CloudTrail CloudWatch Logs Group ARN 설정
- CloudTrail 로그 파일 검증 활성화
- CloudTrail S3 버킷 공개 액세스 차단
- CloudTrail 서버 측 암호화 활성화

### EC2 정책
- EBS 볼륨 암호화 활성화
- EC2 메타데이터 서비스 IMDSv2 필수 설정
- 네트워크 ACL 보안 규칙
- 보안 그룹 인그레스 트래픽 제한 (포트 22, 3389)
- VPC 기본 보안 그룹 트래픽 차단
- VPC 플로우 로깅 활성화

### IAM 정책
- 관리자 권한 정책 제한
- 사용자에게 직접 정책 연결 금지
- 패스워드 정책 (만료, 길이, 복잡성 요구사항)

### S3 정책
- 계정 및 버킷 레벨 퍼블릭 액세스 차단
- SSL/TLS 요구사항
- MFA 삭제 요구사항
- 객체 레벨 로깅 (읽기/쓰기 이벤트)

### 기타 서비스
- **EFS**: 저장 시 암호화 활성화
- **KMS**: 키 로테이션 활성화
- **RDS**: 저장 시 암호화, 자동 마이너 버전 업그레이드, 퍼블릭 액세스 비활성화
- **VPC**: 플로우 로깅 활성화

## 설치 및 설정

### 전제 조건

1. **HCP Terraform 또는 Terraform Enterprise 계정**
   - 기존 워크스페이스가 AWS 액세스 자격 증명으로 구성되어 있어야 함
   - 조직 소유자 권한 또는 "정책 관리" 권한 필요

2. **버전 요구사항**
   - HCP Terraform 또는 Terraform Enterprise v202312-1 이상
   - Sentinel 버전 0.26.x 이상

3. **HashiCorp Sentinel 설치**
   ```bash
   # macOS (Homebrew 사용)
   brew install hashicorp/tap/sentinel
   
   # 또는 공식 웹사이트에서 다운로드
   # https://developer.hashicorp.com/sentinel/install
   ```

### 구현 방법

#### 방법 1: Terraform Registry 사용

1. [Terraform Registry](https://registry.terraform.io/browse/policies)에서 원하는 Sentinel 정책 선택
2. 제공된 정책 스니펫 복사
3. GitHub 저장소 생성 (또는 기존 저장소 사용)
4. `sentinel.hcl` 파일에 정책 스니펫 추가
5. VCS 워크플로우를 통해 Terraform Cloud/Enterprise에 연결

#### 방법 2: GitHub 저장소 직접 사용

1. 이 공개 GitHub 저장소를 포크하거나 직접 사용
2. 안정성을 위해 기본 브랜치 대신 릴리스 브랜치 사용 권장
3. VCS 워크플로우를 통해 Terraform Cloud/Enterprise에 연결
4. Terraform plan 실행으로 정책 적용

#### 방법 3: Terraform 모듈 접근법

1. Sentinel 정책 세트 관리용 전용 Terraform 모듈 사용
2. 최소한의 변수 입력으로 구성
3. 여러 정책 세트를 해당 워크스페이스에 자동 연결

## 정책 구성 및 사용자 정의

### 기본 구성

기본적으로 모든 정책은 `advisory` 강제 수준으로 활성화됩니다:

```hcl
policy "iam-password-expiry" {
  source = "./policies/iam/iam-password-expiry.sentinel"
  enforcement_level = "advisory"
  params = {
    password_expiry_days = 90
  }
}
```

### 강제 수준 변경

필요에 따라 강제 수준을 변경할 수 있습니다:

- `advisory`: 권고 사항 (실패해도 배포 진행)
- `soft-mandatory`: 소프트 필수 (오버라이드 가능)
- `hard-mandatory`: 하드 필수 (오버라이드 불가)

```hcl
policy "ec2-ebs-encryption-enabled" {
  source = "./policies/ec2/ec2-ebs-encryption-enabled.sentinel"
  enforcement_level = "hard-mandatory"
}
```

### 매개변수 사용자 정의

일부 정책은 매개변수를 통해 사용자 정의할 수 있습니다:

```hcl
policy "iam-password-length" {
  source = "./policies/iam/iam-password-length.sentinel"
  enforcement_level = "soft-mandatory"
  params = {
    password_length = 16  # 기본값: 14
  }
}
```

## 테스트 실행

### 로컬 테스트

1. 정책 디렉터리로 이동:
   ```bash
   cd policies/AWS-Resource
   ```

2. 모든 테스트 실행:
   ```bash
   sentinel test
   ```

3. 특정 정책 테스트:
   ```bash
   sentinel test example-policy.sentinel
   ```

### 테스트 구조

```
/policies/AWS-Resource/
├── test/
│   └── example-policy/
│       ├── example-test-1.hcl
│       ├── example-test-2.hcl
│       └── mocks/
│           ├── example-test-1/
│           │   ├── mock-tfconfig-v2.sentinel
│           │   ├── mock-tfplan-v2.sentinel
│           │   └── mock-tfstate-v2.sentinel
│           └── example-test-2/
│               ├── mock-tfconfig-v2.sentinel
│               ├── mock-tfplan-v2.sentinel
│               └── mock-tfstate-v2.sentinel
└── example-policy.sentinel
```

## 모니터링 및 보고

### 정책 실행 결과

정책 실행 후 다음과 같은 정보를 확인할 수 있습니다:

- **성공**: 모든 리소스가 정책을 통과한 경우
- **실패**: 하나 이상의 리소스가 정책을 위반한 경우
- **위반 세부사항**: 위반된 리소스 주소 및 구체적인 오류 메시지

### 보고서 형식

```
→ → Overall Result: false

This result means that not all resources passed the policy check and the protected behavior is not allowed for the policy iam-password-length.

Found 2 resource violations

→ Module name: root
   ↳ Resource Address: aws_iam_account_password_policy.example
     | ✗ failed
     | Attribute 'minimum_password_length' with value 8 must be greater than or equal to 14 for 'aws_iam_account_password_policy' resources.
```

## 모범 사례

### 1. 점진적 구현
- 처음에는 `advisory` 수준으로 시작
- 팀이 익숙해지면 `soft-mandatory`로 변경
- 중요한 보안 정책만 `hard-mandatory`로 설정

### 2. 정기적인 업데이트
- 정책 라이브러리를 정기적으로 업데이트
- 새로운 CIS 벤치마크 버전에 맞춰 조정
- 조직의 보안 요구사항 변화에 따라 사용자 정의

### 3. 문서화
- 조직별 정책 사용자 정의 사항 문서화
- 예외 사항 및 승인 프로세스 정의
- 팀 교육 및 가이드라인 제공

### 4. 모니터링
- 정책 위반 사항 정기적 검토
- 트렌드 분석을 통한 개선점 도출
- 자동화된 알림 설정

## 문제 해결

### 일반적인 문제

1. **정책이 실행되지 않는 경우**
   - Sentinel 버전 확인
   - 정책 파일 경로 확인
   - 워크스페이스 권한 확인

2. **예상과 다른 결과가 나오는 경우**
   - 테스트 케이스로 로컬에서 검증
   - 모의 데이터와 실제 Terraform 상태 비교
   - 정책 로직 디버깅

3. **성능 문제**
   - 대용량 Terraform 상태에서 정책 최적화
   - 불필요한 정책 비활성화
   - 정책 실행 순서 조정

## 지원 및 기여

### 피드백 제공
- [공개 설문조사](https://docs.google.com/forms/d/e/1FAIpQLScswwLMaVaRuYRGJzDjNiycwM4BUa_gAIsAE_zOPdgyFeLXCA/viewform)를 통한 피드백
- [GitHub 이슈](https://github.com/hashicorp/policy-library-CIS-Policy-Set-for-AWS-Terraform/issues/new) 생성
- [기여 가이드](https://github.com/hashicorp/policy-library-CIS-Policy-Set-for-AWS-Terraform/blob/main/CONTRIBUTING.md) 참조

### 추가 리소스
- [HCP Terraform 시작하기](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started)
- [VCS 제공자 연결](https://developer.hashicorp.com/terraform/cloud-docs/vcs)
- [정책 강제 적용](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement)
- [Sentinel 문서](https://developer.hashicorp.com/sentinel/docs)
- [정책 라이브러리](https://registry.terraform.io/browse/policies)

---

이 가이드를 통해 AWS CIS Foundations Benchmark Sentinel 정책을 효과적으로 구현하고 관리할 수 있습니다. 추가 질문이나 지원이 필요한 경우 위의 리소스를 참조하거나 커뮤니티에 문의하시기 바랍니다.
## 한글 출력 
기능

### 적용된 한글화 내용

이 저장소의 Sentinel 정책들은 한국어 사용자를 위해 다음과 같이 한글화되었습니다:

#### 1. 보고서 출력 한글화
- 정책 실행 결과가 한글로 출력됩니다
- 성공/실패 메시지, 위반 사항 개수, 리소스 주소 등 모든 출력이 한글로 표시됩니다

#### 2. 정책 위반 메시지 한글화
주요 정책들의 위반 메시지가 한글로 번역되었습니다:

**S3 정책**
- SSL 요구사항: "S3 범용 버킷은 SSL을 사용하는 요청을 요구해야 합니다"
- 퍼블릭 액세스 차단: "계정/버킷 레벨 Amazon S3 퍼블릭 액세스 차단 설정이 규정을 준수하지 않습니다"
- MFA 삭제: "모든 'aws_s3_bucket' 리소스는 'mfa_delete'가 'Enabled'로 설정된 'aws_s3_bucket_versioning' 리소스와 연결되어야 합니다"

**EC2 정책**
- EBS 암호화: "'aws_ebs_volume' 리소스의 'encrypted' 속성은 true로 설정되어야 합니다"
- 보안 그룹: "보안 그룹 규칙은 0.0.0.0/0 또는 ::/0에서 포트 22/3389로의 인그레스를 허용해서는 안 됩니다"
- VPC 플로우 로깅: "VPC 리소스는 플로우 로깅이 활성화되어야 합니다"

**IAM 정책**
- 패스워드 정책: "'aws_iam_account_password_policy' 리소스의 속성들이 CIS 표준을 준수해야 합니다"
- 관리자 권한: "IAM 정책은 전체 '*' 관리자 권한을 허용해서는 안 됩니다"

**기타 서비스**
- RDS 암호화: "'aws_db_instance' 리소스의 'storage_encrypted' 속성은 true로 설정되어야 합니다"
- KMS 키 로테이션: "'aws_kms_key' 리소스의 'enable_key_rotation' 속성이 활성화되어야 합니다"
- EFS 암호화: "'aws_efs_file_system' 리소스의 암호화 관련 속성들이 올바르게 설정되어야 합니다"
- CloudTrail: "'aws_cloudtrail' 리소스의 보안 관련 속성들이 활성화되어야 합니다"

### 한글 출력 예시

#### 정책 통과 시
```
→ → 전체 결과: true

모든 리소스가 정책 검사를 통과했습니다. 정책명: s3-require-ssl.

✓ 리소스 위반 사항 0개 발견
```

#### 정책 위반 시
```
→ → 전체 결과: false

일부 리소스가 정책 검사를 통과하지 못했으며, 보호된 동작이 허용되지 않습니다. 정책명: ec2-ebs-encryption-enabled.

2개의 리소스 위반 사항 발견

→ 모듈명: root
   ↳ 리소스 주소: aws_ebs_volume.example1
     | ✗ 실패
     | 'aws_ebs_volume' 리소스의 'encrypted' 속성은 true로 설정되어야 합니다. 자세한 내용은 https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-7 을 참조하세요.

   ↳ 리소스 주소: aws_ebs_volume.example2
     | ✗ 실패
     | 'aws_ebs_volume' 리소스의 'encrypted' 속성은 true로 설정되어야 합니다. 자세한 내용은 https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-7 을 참조하세요.
```

### 추가 한글화 방법

더 많은 정책을 한글화하려면:

1. **정책 파일 수정**: `policies/` 디렉터리의 `.sentinel` 파일에서 `message` 상수를 한글로 변경
2. **동적 메시지 함수 수정**: `generate_violation_message` 같은 함수에서 반환하는 문자열을 한글로 변경
3. **테스트**: `sentinel test` 명령으로 정책이 올바르게 작동하는지 확인

### 기술적 세부사항

- **인코딩**: 모든 파일은 UTF-8 인코딩을 사용합니다
- **호환성**: 기존 Sentinel 문법과 완전히 호환됩니다
- **성능**: 메시지 번역으로 인한 성능 영향은 없습니다
- **유지보수**: 정책 로직은 변경되지 않고 메시지만 한글화되었습니다

이제 한국어 사용자들이 AWS CIS Benchmark 정책 위반 사항을 더 쉽게 이해하고 대응할 수 있습니다.