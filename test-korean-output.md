# 한글 출력 테스트 가이드

## 수정된 내용 요약

### 1. Report 모듈 한글화
- `modules/report/report.sentinel` 파일의 메시지들을 한글로 변경
- 전체 결과, 성공/실패 메시지, 위반 사항 카운트 등 모두 한글로 출력

### 2. 주요 정책 메시지 한글화
다음 정책들의 오류 메시지를 한글로 변경했습니다:

#### S3 정책
- `s3-require-ssl.sentinel`: SSL 요구사항 메시지
- `s3-block-public-access-account-level.sentinel`: 계정 레벨 퍼블릭 액세스 차단
- `s3-block-public-access-bucket-level.sentinel`: 버킷 레벨 퍼블릭 액세스 차단
- `s3-require-mfa-delete.sentinel`: MFA 삭제 요구사항

#### EC2 정책
- `ec2-ebs-encryption-enabled.sentinel`: EBS 암호화 요구사항
- `ec2-vpc-flow-logging-enabled.sentinel`: VPC 플로우 로깅 요구사항

#### IAM 정책
- `iam-password-length.sentinel`: 패스워드 길이 요구사항
- `iam-password-expiry.sentinel`: 패스워드 만료 요구사항
- `iam-password-lowercase.sentinel`: 소문자 요구사항
- `iam-password-uppercase.sentinel`: 대문자 요구사항
- `iam-no-admin-privileges-allowed-by-policies.sentinel`: 관리자 권한 제한

#### 기타 서비스
- `rds-encryption-at-rest-enabled.sentinel`: RDS 저장 시 암호화
- `kms-key-rotation-enabled.sentinel`: KMS 키 로테이션
- `efs-encryption-at-rest-enabled.sentinel`: EFS 저장 시 암호화
- `cloudtrail-server-side-encryption-enabled.sentinel`: CloudTrail 서버 측 암호화

## 테스트 방법

### 1. 로컬 테스트
```bash
# 특정 정책 테스트
cd policies/s3
sentinel test s3-require-ssl.sentinel

# 모든 테스트 실행
cd policies
sentinel test
```

### 2. 예상 출력 형식

#### 성공 시:
```
→ → 전체 결과: true

모든 리소스가 정책 검사를 통과했습니다. 정책명: s3-require-ssl.

✓ 리소스 위반 사항 0개 발견
```

#### 실패 시:
```
→ → 전체 결과: false

일부 리소스가 정책 검사를 통과하지 못했으며, 보호된 동작이 허용되지 않습니다. 정책명: s3-require-ssl.

2개의 리소스 위반 사항 발견

→ 모듈명: root
   ↳ 리소스 주소: aws_s3_bucket.example
     | ✗ 실패
     | S3 범용 버킷은 SSL을 사용하는 요청을 요구해야 합니다. 자세한 내용은 https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-5 를 참조하세요.
```

## 추가 개선 사항

### 1. 남은 정책들 한글화
아직 한글화되지 않은 정책들이 있습니다. 필요시 동일한 방식으로 수정할 수 있습니다:

- CloudTrail 관련 정책들
- VPC 관련 정책들  
- 보안 그룹 관련 정책들
- 기타 IAM 정책들

### 2. 매개변수 메시지 한글화
일부 정책에서 동적으로 생성되는 메시지들도 한글화할 수 있습니다.

### 3. 테스트 케이스 한글화
필요시 테스트 케이스의 설명이나 메시지도 한글로 변경할 수 있습니다.

## 사용법

1. 수정된 정책들을 HCP Terraform 또는 Terraform Enterprise에 배포
2. Terraform plan 실행 시 정책 위반 사항이 한글로 출력됨
3. 팀원들이 더 쉽게 이해할 수 있는 한글 메시지로 컴플라이언스 검사 결과 확인

이제 AWS CIS Benchmark Sentinel 정책들이 한글로 출력되어 한국어 사용자들이 더 쉽게 이해하고 대응할 수 있습니다.