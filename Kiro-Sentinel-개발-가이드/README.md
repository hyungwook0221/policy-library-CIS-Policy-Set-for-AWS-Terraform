# Kiro와 Amazon Q를 활용한 Sentinel 개발 가이드

## 개요

이 가이드는 HCP Terraform 및 Terraform Enterprise 사용자들이 Kiro IDE의 고급 기능들과 MCP(Model Context Protocol)를 활용하여 효율적으로 Sentinel 정책을 개발할 수 있도록 돕는 종합 가이드입니다.

## 목차

### 📚 기초 학습
- [Sentinel 문법 및 기본 개념](./01-basics/01-sentinel-syntax.md)
- [Terraform 데이터 접근](./01-basics/02-terraform-data-access.md)
- [정책 구조 및 모범 사례](./01-basics/03-policy-structure.md)

### 🛠️ Kiro IDE 활용
- [Spec 기반 개발 프로세스](./02-kiro-features/01-spec-development.md)
- [Agent Hooks 설정 및 활용](./02-kiro-features/02-agent-hooks.md)
- [Agent Steering 구성](./02-kiro-features/03-agent-steering.md)

### 🔌 MCP 통합
- [AWS Documentation MCP 활용](./03-mcp-integration/01-aws-docs-mcp.md)
- [Terraform Registry MCP 활용](./03-mcp-integration/02-terraform-registry-mcp.md)
- [Diagram Generation MCP 활용](./03-mcp-integration/03-diagram-mcp.md)

### 📋 정책 템플릿
- [보안 정책 템플릿](./04-templates/01-security-policies/)
- [비용 최적화 정책 템플릿](./04-templates/02-cost-optimization/)
- [운영 정책 템플릿](./04-templates/03-operational-policies/)

### 🧪 테스팅 및 디버깅
- [단위 테스트 작성](./05-testing/01-unit-testing.md)
- [통합 테스트 및 시나리오 테스트](./05-testing/02-integration-testing.md)
- [디버깅 및 성능 최적화](./05-testing/03-debugging-optimization.md)

### 🔄 Git 워크플로우 및 CI/CD
- [Git 브랜치 전략 및 커밋 규칙](./06-git-cicd/01-git-workflow.md)
- [GitHub Actions CI/CD 파이프라인](./06-git-cicd/02-cicd-pipeline.md)

### 🏢 조직별 커스터마이징
- [조직 표준 설정](./07-customization/01-organization-standards.md)
- [교육 자료 및 온보딩](./07-customization/02-training-onboarding.md)
- [메트릭 수집 및 모니터링](./07-customization/03-metrics-monitoring.md)

### 💡 실제 사례 및 베스트 프랙티스
- [업계별 정책 사례 연구](./08-case-studies/01-industry-cases.md)
- [일반적인 문제 해결](./08-case-studies/02-troubleshooting.md)

### 🎯 실습 환경
- [Kiro IDE 실습 환경 설정](./09-hands-on/01-lab-setup.md)
- [인터랙티브 튜토리얼](./09-hands-on/02-interactive-tutorials.md)

## 빠른 시작

### 1. 환경 설정
```bash
# Kiro IDE에서 새 프로젝트 생성
mkdir my-sentinel-policies
cd my-sentinel-policies

# 기본 구조 생성
mkdir -p policies/{security,cost,operational}
mkdir -p test/mocks
mkdir -p .kiro/{steering,hooks}
```

### 2. 첫 번째 정책 작성
```sentinel
# policies/security/ec2-instance-type.sentinel
import "tfplan/v2" as tfplan
import "tfresources" as tf

# 허용되는 인스턴스 타입
allowed_instance_types = ["t3.micro", "t3.small", "t3.medium"]

# EC2 인스턴스 리소스 가져오기
ec2_instances = tf.plan(tfplan.planned_values.resources).type("aws_instance").resources

# 정책 규칙
main = rule {
    all ec2_instances as _, instance {
        instance.values.instance_type in allowed_instance_types
    }
}
```

### 3. Kiro Spec 생성
```bash
# Kiro IDE에서 새 Spec 생성
# 요구사항 → 설계 → 구현 순서로 체계적 개발
```

## 주요 특징

- ✅ **체계적인 학습 경로**: 기초부터 고급까지 단계별 학습
- ✅ **Kiro IDE 완전 활용**: Spec, Hooks, Steering 등 모든 기능 활용
- ✅ **MCP 통합**: AWS 문서, Terraform Registry 등 외부 도구 연동
- ✅ **실무 중심**: 실제 기업 환경에서 사용할 수 있는 템플릿과 사례
- ✅ **자동화 지원**: CI/CD 파이프라인 및 자동 테스트 구성
- ✅ **한국어 지원**: 모든 가이드와 예제가 한국어로 제공

## 기여하기

이 가이드는 지속적으로 업데이트됩니다. 개선 사항이나 새로운 사례가 있다면 기여해주세요.

1. 이슈 생성 또는 기존 이슈 확인
2. 브랜치 생성 (`git checkout -b feature/new-guide`)
3. 변경사항 커밋 (`git commit -am 'Add new guide'`)
4. 브랜치 푸시 (`git push origin feature/new-guide`)
5. Pull Request 생성

## 라이선스

이 가이드는 MIT 라이선스 하에 제공됩니다.

## 지원

- 📧 이메일: sentinel-support@example.com
- 💬 Slack: #sentinel-development
- 📖 위키: [내부 위키 링크]

---

**시작하기**: [Sentinel 문법 및 기본 개념](./01-basics/01-sentinel-syntax.md)부터 시작하세요!