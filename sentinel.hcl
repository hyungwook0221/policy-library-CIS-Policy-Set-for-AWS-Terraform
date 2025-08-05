# Sentinel 정책 설정 - 실제 운영 환경 권장 설정
# 보안 위험도와 비즈니스 영향도를 고려한 단계별 enforcement level 적용

# 🚨 HARD MANDATORY - 절대 허용할 수 없는 치명적 보안 위험
# 이 정책들은 즉시 해킹이나 데이터 유출로 이어질 수 있는 위험들

# 1. 인터넷에서 관리 포트 직접 접근 - 즉시 해킹 위험
policy "ec2-security-group-ingress-traffic-restriction-port-22" {
  source = "./policies/ec2/ec2-security-group-ingress-traffic-restriction-port.sentinel"
  enforcement_level = "hard-mandatory"
  params = {
    port = 22
  }
  # 근거: SSH 포트를 인터넷에 개방하면 브루트포스 공격으로 즉시 침해 가능
  # 비즈니스 영향: 서버 완전 장악, 데이터 유출, 랜섬웨어 등 치명적 피해
}

policy "ec2-security-group-ingress-traffic-restriction-port-3389" {
  source = "./policies/ec2/ec2-security-group-ingress-traffic-restriction-port.sentinel"
  enforcement_level = "hard-mandatory"
  params = {
    port = 3389
  }
  # 근거: RDP 포트 개방은 Windows 서버 직접 접근 허용, 매우 위험
  # 비즈니스 영향: 원격 데스크톱을 통한 완전한 시스템 제어권 탈취
}

# 2. 과도한 권한 부여 - 내부자 위협 및 권한 남용
policy "iam-no-admin-privileges-allowed-by-policies" {
  source = "./policies/iam/iam-no-admin-privileges-allowed-by-policies.sentinel"
  enforcement_level = "hard-mandatory"
  # 근거: 관리자 권한(*:*)은 모든 AWS 리소스에 대한 완전한 제어권 부여
  # 비즈니스 영향: 계정 탈취 시 전체 인프라 파괴, 데이터 삭제, 비용 폭탄 가능
}

# 3. 데이터 유출 직접 경로 - 퍼블릭 데이터 노출
policy "s3-block-public-access-bucket-level" {
  source = "./policies/s3/s3-block-public-access-bucket-level.sentinel"
  enforcement_level = "hard-mandatory"
  # 근거: S3 퍼블릭 액세스는 민감한 데이터가 인터넷에 직접 노출됨
  # 비즈니스 영향: 개인정보, 기업기밀 등 대량 데이터 유출, 법적 책임
}

policy "s3-block-public-access-account-level" {
  source = "./policies/s3/s3-block-public-access-account-level.sentinel"
  enforcement_level = "hard-mandatory"
  # 근거: 계정 레벨 퍼블릭 액세스 차단은 모든 S3 버킷의 기본 보안 설정
  # 비즈니스 영향: 실수로 퍼블릭 설정된 버킷들로 인한 대규모 데이터 유출 방지
}

# 🔶 SOFT MANDATORY - 중요하지만 특정 상황에서 예외가 필요할 수 있는 정책
# 보안팀 승인 하에 override 가능

# 1. 암호화 정책 - 규정 준수 및 데이터 보호
policy "rds-encryption-at-rest-enabled" {
  source = "./policies/rds/rds-encryption-at-rest-enabled.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 데이터베이스 암호화는 GDPR, HIPAA 등 규정 준수 필수
  # 예외 상황: 개발/테스트 환경, 성능 테스트, 레거시 시스템 마이그레이션
}

policy "ec2-ebs-encryption-enabled" {
  source = "./policies/ec2/ec2-ebs-encryption-enabled.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 디스크 암호화는 물리적 접근 시 데이터 보호
  # 예외 상황: 임시 테스트 인스턴스, 성능 벤치마킹, 특정 애플리케이션 호환성
}

policy "efs-encryption-at-rest-enabled" {
  source = "./policies/efs/efs-encryption-at-rest-enabled.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 공유 파일 시스템의 데이터 보호
  # 예외 상황: 개발 환경, 임시 데이터 저장소
}

# 2. 네트워크 보안 - 중요하지만 아키텍처에 따라 예외 필요
policy "ec2-vpc-default-security-group-no-traffic" {
  source = "./policies/ec2/ec2-vpc-default-security-group-no-traffic.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 기본 보안 그룹은 의도치 않은 트래픽 허용 방지
  # 예외 상황: 특정 아키텍처 패턴, 레거시 시스템 호환성
}

policy "rds-public-access-disabled" {
  source = "./policies/rds/rds-public-access-disabled.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 데이터베이스는 일반적으로 내부 네트워크에서만 접근
  # 예외 상황: 외부 파트너 연동, 특정 SaaS 아키텍처, 개발 편의성
}

# 3. 접근 제어 - 보안 모범 사례
policy "iam-no-policies-attached-to-users" {
  source = "./policies/iam/iam-no-policies-attached-to-users.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 그룹/역할 기반 권한 관리가 모범 사례
  # 예외 상황: 서비스 계정, 임시 권한 부여, 특수 목적 사용자
}

policy "ec2-metadata-imdsv2-required" {
  source = "./policies/ec2/ec2-metadata-imdsv2-required.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: IMDSv2는 SSRF 공격 방지, 보안 강화
  # 예외 상황: 레거시 애플리케이션, 특정 라이브러리 호환성 문제
}

policy "s3-require-ssl" {
  source = "./policies/s3/s3-require-ssl.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 전송 중 데이터 암호화 필수
  # 예외 상황: 내부 네트워크 전용, 특정 통합 시나리오
}

policy "kms-key-rotation-enabled" {
  source = "./policies/kms/kms-key-rotation-enabled.sentinel"
  enforcement_level = "soft-mandatory"
  # 근거: 정기적 키 로테이션은 보안 모범 사례
  # 예외 상황: 외부 시스템 연동 키, 특정 규정 요구사항
}

# 📋 ADVISORY - 모범 사례이지만 비즈니스 요구사항에 따라 유연하게 적용
# 경고만 표시, 개발팀 판단에 맡김

# 1. 운영 및 모니터링 - 중요하지만 즉시 보안 위험은 아님
policy "ec2-vpc-flow-logging-enabled" {
  source = "./policies/ec2/ec2-vpc-flow-logging-enabled.sentinel"
  enforcement_level = "advisory"
  # 근거: 네트워크 모니터링은 중요하지만 즉시 보안 위험은 아님
  # 고려사항: 비용, 로그 저장소 용량, 분석 도구 준비 상태
}

policy "vpc-flow-logging-enabled" {
  source = "./policies/vpc/vpc-flow-logging-enabled.sentinel"
  enforcement_level = "advisory"
  # 근거: VPC 레벨 플로우 로깅, 운영 성숙도에 따라 적용
  # 고려사항: 조직의 모니터링 역량, 비용 대비 효과
}

policy "cloudtrail-server-side-encryption-enabled" {
  source = "./policies/cloudtrail/cloudtrail-server-side-encryption-enabled.sentinel"
  enforcement_level = "advisory"
  # 근거: CloudTrail 로그 암호화는 좋지만 필수는 아님
  # 고려사항: 로그 분석 도구 호환성, 추가 복잡성
}

policy "cloudtrail-log-file-validation-enabled" {
  source = "./policies/cloudtrail/cloudtrail-log-file-validation-enabled.sentinel"
  enforcement_level = "advisory"
  # 근거: 로그 무결성 검증, 포렌식 목적
  # 고려사항: 실제 활용 계획, 분석 도구 지원
}

policy "cloudtrail-cloudwatch-logs-group-arn-present" {
  source = "./policies/cloudtrail/cloudtrail-cloudwatch-logs-group-arn-present.sentinel"
  enforcement_level = "advisory"
  # 근거: 실시간 모니터링 연동
  # 고려사항: CloudWatch 비용, 알람 설정 준비 상태
}

policy "cloudtrail-logs-bucket-not-public" {
  source = "./policies/cloudtrail/cloudtrail-logs-bucket-not-public.sentinel"
  enforcement_level = "advisory"
  # 근거: CloudTrail 로그 버킷 보안
  # 고려사항: 일반적으로 퍼블릭으로 설정할 이유가 없음
}

policy "cloudtrail-bucket-access-logging-enabled" {
  source = "./policies/cloudtrail/cloudtrail-bucket-access-logging-enabled.sentinel"
  enforcement_level = "advisory"
  # 근거: 로그 버킷 접근 추적
  # 고려사항: 추가 로그 저장 비용, 분석 복잡성
}

# 2. S3 고급 보안 기능 - 조직 성숙도에 따라 적용
policy "s3-require-mfa-delete" {
  source = "./policies/s3/s3-require-mfa-delete.sentinel"
  enforcement_level = "advisory"
  # 근거: MFA Delete는 매우 강력한 보안이지만 운영 복잡성 증가
  # 고려사항: 조직의 MFA 정책, 운영 프로세스 준비 상태
}

policy "s3-enable-object-logging-for-write-events" {
  source = "./policies/s3/s3-enable-object-logging-for-events.sentinel"
  enforcement_level = "advisory"
  params = {
    event_type = "WriteOnly"
  }
  # 근거: S3 객체 레벨 로깅은 상세한 감사 추적 제공
  # 고려사항: 대량 로그 생성, CloudTrail 비용 증가
}

policy "s3-enable-object-logging-for-read-events" {
  source = "./policies/s3/s3-enable-object-logging-for-events.sentinel"
  enforcement_level = "advisory"
  params = {
    event_type = "ReadOnly"
  }
  # 근거: 읽기 이벤트 로깅은 매우 상세한 추적
  # 고려사항: 매우 많은 로그 생성, 비용 대비 효과 검토 필요
}

# 3. 시스템 관리 정책 - 운영 편의성과 보안의 균형
policy "rds-minor-version-upgrade-enabled" {
  source = "./policies/rds/rds-minor-version-upgrade-enabled.sentinel"
  enforcement_level = "advisory"
  # 근거: 자동 업그레이드는 보안 패치 적용에 좋지만 안정성 위험
  # 고려사항: 애플리케이션 호환성, 변경 관리 프로세스
}

policy "ec2-network-acl" {
  source = "./policies/ec2/ec2-network-acl.sentinel"
  enforcement_level = "advisory"
  # 근거: Network ACL 설정은 추가 보안 계층
  # 고려사항: 보안 그룹과 중복, 관리 복잡성 증가
}

# 4. IAM 패스워드 정책 - 조직 정책에 따라 조정
policy "iam-password-expiry" {
  source = "./policies/iam/iam-password-expiry.sentinel"
  enforcement_level = "advisory"
  params = {
    password_expiry_days = 90
  }
  # 근거: 패스워드 만료는 전통적 보안 정책이지만 현대적 관점에서는 논란
  # 고려사항: NIST 가이드라인 변화, 사용자 경험, MFA 사용 여부
}

policy "iam-password-length" {
  source = "./policies/iam/iam-password-length.sentinel"
  enforcement_level = "advisory"
  params = {
    password_length = 14
  }
  # 근거: 긴 패스워드는 보안에 좋지만 사용성 저하
  # 고려사항: 조직의 패스워드 정책, MFA 의존도
}

policy "iam-password-lowercase" {
  source = "./policies/iam/iam-password-lowercase.sentinel"
  enforcement_level = "advisory"
  # 근거: 복잡성 요구사항, 조직 정책에 따라 결정
}

policy "iam-password-numbers" {
  source = "./policies/iam/iam-password-numbers.sentinel"
  enforcement_level = "advisory"
  # 근거: 숫자 포함 요구사항, 현대적 보안에서는 길이가 더 중요
}

policy "iam-password-reuse" {
  source = "./policies/iam/iam-password-reuse.sentinel"
  enforcement_level = "advisory"
  params = {
    allowed_password_reuse_limit = 24
  }
  # 근거: 패스워드 재사용 방지, 하지만 사용자 불편 증가
}

policy "iam-password-symbols" {
  source = "./policies/iam/iam-password-symbols.sentinel"
  enforcement_level = "advisory"
  # 근거: 특수문자 요구사항, 사용성과 보안의 균형
}

policy "iam-password-uppercase" {
  source = "./policies/iam/iam-password-uppercase.sentinel"
  enforcement_level = "advisory"
  # 근거: 대문자 요구사항, 복잡성보다는 길이가 더 효과적
}