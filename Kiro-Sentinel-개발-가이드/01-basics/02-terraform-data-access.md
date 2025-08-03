# Terraform 데이터 접근 가이드

## 개요

Sentinel 정책에서 가장 중요한 부분은 Terraform 데이터에 접근하여 인프라스트럭처 구성을 검증하는 것입니다. Terraform은 세 가지 주요 데이터 소스를 제공합니다: **tfplan**, **tfconfig**, **tfstate**. 이 가이드에서는 각 데이터 소스의 구조와 활용 방법을 상세히 설명합니다.

## Terraform 데이터 소스 개요

| 데이터 소스 | 용도 | 시점 | 주요 사용 사례 |
|------------|------|------|----------------|
| **tfplan** | 계획된 변경사항 | `terraform plan` 후 | 리소스 생성/수정/삭제 검증 |
| **tfconfig** | 구성 정의 | 정적 분석 | 코드 구조, 모듈 사용 검증 |
| **tfstate** | 현재 상태 | 실행 시점 | 기존 리소스 상태 확인 |

## 1. tfplan - 계획된 변경사항

### 1.1 기본 구조

```sentinel
import "tfplan/v2" as tfplan

# tfplan의 주요 구조
# tfplan.planned_values    - 계획된 최종 상태
# tfplan.resource_changes  - 리소스별 변경사항
# tfplan.configuration     - 구성 정보
# tfplan.variables         - 입력 변수
```

### 1.2 planned_values 활용

```sentinel
# 계획된 최종 상태의 모든 리소스 접근
all_resources = tfplan.planned_values.resources

# 특정 타입의 리소스 필터링
ec2_instances = filter all_resources as _, resource {
    resource.type == "aws_instance"
}

# 리소스 속성 접근
for ec2_instances as _, instance {
    print("인스턴스 주소:", instance.address)
    print("인스턴스 타입:", instance.values.instance_type)
    print("AMI ID:", instance.values.ami)
    print("서브넷 ID:", instance.values.subnet_id)
}
```

### 1.3 resource_changes 활용

```sentinel
# 변경사항이 있는 리소스만 확인
resource_changes = tfplan.resource_changes

# 생성될 리소스만 필터링
creating_resources = filter resource_changes as _, rc {
    rc.change.actions contains "create"
}

# 수정될 리소스만 필터링
updating_resources = filter resource_changes as _, rc {
    rc.change.actions contains "update"
}

# 삭제될 리소스만 필터링
deleting_resources = filter resource_changes as _, rc {
    rc.change.actions contains "delete"
}

# 변경 전후 값 비교
for updating_resources as _, resource {
    print("리소스:", resource.address)
    print("변경 전:", resource.change.before)
    print("변경 후:", resource.change.after)
    
    # 특정 속성 변경 확인
    if resource.change.before.instance_type != resource.change.after.instance_type {
        print("인스턴스 타입 변경:", 
              resource.change.before.instance_type, "→", 
              resource.change.after.instance_type)
    }
}
```

### 1.4 실제 사용 예제

```sentinel
# EC2 인스턴스 보안 그룹 검증
import "tfplan/v2" as tfplan

# 새로 생성되는 EC2 인스턴스 확인
new_instances = filter tfplan.resource_changes as _, rc {
    rc.type == "aws_instance" and
    rc.mode == "managed" and
    rc.change.actions contains "create"
}

# 보안 그룹 검증
violations = []
for new_instances as _, instance {
    security_groups = instance.change.after.security_groups
    
    # 기본 보안 그룹 사용 금지
    for security_groups as _, sg {
        if sg == "default" {
            violation = {
                "resource": instance.address,
                "message": "기본 보안 그룹 사용이 금지됩니다"
            }
            append(violations, violation)
        }
    }
}

main = rule {
    length(violations) == 0
}
```

## 2. tfconfig - 구성 정의

### 2.1 기본 구조

```sentinel
import "tfconfig/v2" as tfconfig

# tfconfig의 주요 구조
# tfconfig.resources       - 리소스 정의
# tfconfig.modules         - 모듈 정의
# tfconfig.variables       - 변수 정의
# tfconfig.outputs         - 출력 정의
```

### 2.2 리소스 구성 분석

```sentinel
# 모든 리소스 구성 확인
all_resources = tfconfig.resources

# 특정 타입의 리소스 구성
s3_buckets = filter all_resources as _, resource {
    resource.type == "aws_s3_bucket"
}

# 리소스 구성 세부사항 접근
for s3_buckets as _, bucket {
    print("버킷 주소:", bucket.address)
    print("모듈 주소:", bucket.module_address)
    
    # 구성 값 접근
    if "bucket" in keys(bucket.config) {
        bucket_config = bucket.config.bucket
        
        # 상수 값
        if "constant_value" in keys(bucket_config) {
            print("버킷명 (상수):", bucket_config.constant_value)
        }
        
        # 참조 값
        if "references" in keys(bucket_config) {
            print("버킷명 (참조):", bucket_config.references)
        }
    }
}
```

### 2.3 모듈 사용 분석

```sentinel
# 사용된 모듈 확인
modules = tfconfig.modules

for modules as address, module {
    print("모듈 주소:", address)
    print("모듈 소스:", module.source)
    print("모듈 버전:", module.version)
    
    # 모듈 입력 변수
    if "variables" in keys(module) {
        for module.variables as name, variable {
            print("변수:", name, "기본값:", variable.default)
        }
    }
}
```

### 2.4 실제 사용 예제

```sentinel
# 하드코딩된 값 검증
import "tfconfig/v2" as tfconfig

# S3 버킷 이름 하드코딩 검증
s3_buckets = filter tfconfig.resources as _, resource {
    resource.type == "aws_s3_bucket"
}

hardcoded_violations = []
for s3_buckets as _, bucket {
    if "bucket" in keys(bucket.config) {
        bucket_config = bucket.config.bucket
        
        # 상수 값이 있으면 하드코딩으로 간주
        if "constant_value" in keys(bucket_config) {
            violation = {
                "resource": bucket.address,
                "value": bucket_config.constant_value,
                "message": "S3 버킷 이름이 하드코딩되어 있습니다"
            }
            append(hardcoded_violations, violation)
        }
    }
}

main = rule {
    length(hardcoded_violations) == 0
}
```

## 3. tfstate - 현재 상태

### 3.1 기본 구조

```sentinel
import "tfstate/v2" as tfstate

# tfstate의 주요 구조
# tfstate.resources        - 현재 상태의 리소스
# tfstate.outputs          - 출력 값
```

### 3.2 현재 상태 리소스 접근

```sentinel
# 현재 상태의 모든 리소스
current_resources = tfstate.resources

# 관리되는 리소스만 필터링
managed_resources = filter current_resources as _, resource {
    resource.mode == "managed"
}

# 데이터 소스만 필터링
data_resources = filter current_resources as _, resource {
    resource.mode == "data"
}

# 특정 타입의 현재 리소스
current_instances = filter managed_resources as _, resource {
    resource.type == "aws_instance"
}

for current_instances as _, instance {
    print("인스턴스 주소:", instance.address)
    print("현재 상태:", instance.values.state)
    print("퍼블릭 IP:", instance.values.public_ip)
}
```

### 3.3 실제 사용 예제

```sentinel
# 기존 리소스와의 충돌 검증
import "tfplan/v2" as tfplan
import "tfstate/v2" as tfstate

# 새로 생성할 S3 버킷
new_buckets = filter tfplan.resource_changes as _, rc {
    rc.type == "aws_s3_bucket" and
    rc.change.actions contains "create"
}

# 현재 존재하는 S3 버킷
existing_buckets = filter tfstate.resources as _, resource {
    resource.type == "aws_s3_bucket" and
    resource.mode == "managed"
}

# 버킷 이름 충돌 검사
name_conflicts = []
for new_buckets as _, new_bucket {
    new_name = new_bucket.change.after.bucket
    
    for existing_buckets as _, existing_bucket {
        existing_name = existing_bucket.values.bucket
        
        if new_name == existing_name {
            conflict = {
                "new_resource": new_bucket.address,
                "existing_resource": existing_bucket.address,
                "bucket_name": new_name,
                "message": "버킷 이름이 기존 리소스와 충돌합니다"
            }
            append(name_conflicts, conflict)
        }
    }
}

main = rule {
    length(name_conflicts) == 0
}
```

## 4. 고급 데이터 접근 패턴

### 4.1 tfresources 모듈 활용

```sentinel
import "tfplan/v2" as tfplan
import "tfresources" as tf

# tfresources 모듈을 사용한 간편한 리소스 접근
ec2_instances = tf.plan(tfplan.planned_values.resources).type("aws_instance").resources

# 체이닝을 통한 복합 필터링
web_instances = tf.plan(tfplan.planned_values.resources)
    .type("aws_instance")
    .filter(func(r) { 
        return "web" in r.address 
    })
    .resources

# 여러 조건을 만족하는 리소스
production_instances = tf.plan(tfplan.planned_values.resources)
    .type("aws_instance")
    .filter(func(r) {
        return r.values.tags.Environment == "production" and
               r.values.instance_type in ["t3.large", "t3.xlarge"]
    })
    .resources
```

### 4.2 모듈 간 데이터 연관성 분석

```sentinel
import "tfplan/v2" as tfplan
import "strings"

# 모듈별 리소스 그룹화
group_resources_by_module = func(resources) {
    module_groups = {}
    
    for resources as _, resource {
        module_addr = resource.module_address
        if module_addr == "" {
            module_addr = "root"
        }
        
        if module_addr not in keys(module_groups) {
            module_groups[module_addr] = []
        }
        
        append(module_groups[module_addr], resource)
    }
    
    return module_groups
}

# 사용 예제
all_resources = tfplan.planned_values.resources
module_groups = group_resources_by_module(all_resources)

for module_groups as module_addr, resources {
    print("모듈:", module_addr)
    print("리소스 수:", length(resources))
    
    # 모듈별 리소스 타입 분석
    resource_types = {}
    for resources as _, resource {
        type = resource.type
        if type not in keys(resource_types) {
            resource_types[type] = 0
        }
        resource_types[type] += 1
    }
    
    for resource_types as type, count {
        print("  -", type, ":", count, "개")
    }
}
```

### 4.3 변수와 출력 값 활용

```sentinel
import "tfplan/v2" as tfplan

# 입력 변수 접근
variables = tfplan.variables

for variables as name, variable {
    print("변수명:", name)
    print("값:", variable.value)
    
    # 민감한 변수 확인
    if variable.sensitive {
        print("⚠️ 민감한 변수입니다")
    }
}

# 출력 값 접근 (tfplan에서는 계획된 출력)
if "planned_values" in keys(tfplan) and "outputs" in keys(tfplan.planned_values) {
    outputs = tfplan.planned_values.outputs
    
    for outputs as name, output {
        print("출력명:", name)
        if not output.sensitive {
            print("값:", output.value)
        } else {
            print("값: [민감한 정보]")
        }
    }
}
```

## 5. 실전 예제: 종합 보안 검증

```sentinel
# 종합 보안 검증 정책
import "tfplan/v2" as tfplan
import "tfconfig/v2" as tfconfig
import "tfstate/v2" as tfstate
import "strings"

# 1. tfplan을 사용한 새 리소스 보안 검증
validate_new_resources = func() {
    violations = []
    
    # 새로 생성되는 EC2 인스턴스
    new_instances = filter tfplan.resource_changes as _, rc {
        rc.type == "aws_instance" and
        rc.change.actions contains "create"
    }
    
    for new_instances as _, instance {
        values = instance.change.after
        
        # 퍼블릭 IP 할당 검증
        if values.associate_public_ip_address {
            violation = {
                "resource": instance.address,
                "type": "public_ip",
                "message": "퍼블릭 IP 할당이 금지됩니다"
            }
            append(violations, violation)
        }
        
        # 루트 볼륨 암호화 검증
        if "root_block_device" in keys(values) {
            root_device = values.root_block_device[0]
            if not root_device.encrypted {
                violation = {
                    "resource": instance.address,
                    "type": "encryption",
                    "message": "루트 볼륨이 암호화되지 않았습니다"
                }
                append(violations, violation)
            }
        }
    }
    
    return violations
}

# 2. tfconfig를 사용한 구성 검증
validate_configuration = func() {
    violations = []
    
    # 하드코딩된 시크릿 검증
    all_resources = tfconfig.resources
    
    for all_resources as _, resource {
        for resource.config as key, config {
            if "constant_value" in keys(config) {
                value = strings.to_lower(string(config.constant_value))
                
                # 의심스러운 패턴 검사
                suspicious_patterns = ["password", "secret", "key", "token"]
                for suspicious_patterns as _, pattern {
                    if pattern in value {
                        violation = {
                            "resource": resource.address,
                            "attribute": key,
                            "type": "hardcoded_secret",
                            "message": "하드코딩된 시크릿이 의심됩니다: " + key
                        }
                        append(violations, violation)
                    }
                }
            }
        }
    }
    
    return violations
}

# 3. tfstate를 사용한 기존 상태 검증
validate_existing_state = func() {
    violations = []
    
    # 기존 보안 그룹 규칙 검증
    existing_sgs = filter tfstate.resources as _, resource {
        resource.type == "aws_security_group" and
        resource.mode == "managed"
    }
    
    for existing_sgs as _, sg {
        if "ingress" in keys(sg.values) {
            for sg.values.ingress as _, rule {
                # 0.0.0.0/0 허용 규칙 검사
                if rule.cidr_blocks contains "0.0.0.0/0" {
                    violation = {
                        "resource": sg.address,
                        "type": "open_security_group",
                        "message": "보안 그룹이 모든 IP에 대해 열려있습니다"
                    }
                    append(violations, violation)
                }
            }
        }
    }
    
    return violations
}

# 모든 검증 실행
all_violations = []
all_violations += validate_new_resources()
all_violations += validate_configuration()
all_violations += validate_existing_state()

# 결과 출력
if length(all_violations) > 0 {
    print("=== 보안 검증 결과 ===")
    for all_violations as _, violation {
        print("리소스:", violation.resource)
        print("유형:", violation.type)
        print("메시지:", violation.message)
        print("---")
    }
}

main = rule {
    length(all_violations) == 0
}
```

## 6. 성능 최적화 팁

### 6.1 효율적인 필터링

```sentinel
# ❌ 비효율적 - 모든 리소스를 순회
all_resources = tfplan.planned_values.resources
ec2_count = 0
for all_resources as _, resource {
    if resource.type == "aws_instance" {
        ec2_count += 1
    }
}

# ✅ 효율적 - 필터를 먼저 적용
ec2_instances = filter tfplan.planned_values.resources as _, resource {
    resource.type == "aws_instance"
}
ec2_count = length(ec2_instances)
```

### 6.2 중복 계산 방지

```sentinel
# ❌ 비효율적 - 중복 계산
validate_instance_1 = func(instance) {
    expensive_calculation = complex_validation(instance)
    return expensive_calculation.result
}

validate_instance_2 = func(instance) {
    expensive_calculation = complex_validation(instance)  # 중복!
    return expensive_calculation.details
}

# ✅ 효율적 - 결과 캐싱
validation_cache = {}

get_validation_result = func(instance) {
    if instance.address not in keys(validation_cache) {
        validation_cache[instance.address] = complex_validation(instance)
    }
    return validation_cache[instance.address]
}
```

## 다음 단계

Terraform 데이터 접근 방법을 익혔으니, 다음 가이드에서는 정책 구조와 모범 사례를 학습하겠습니다:

- [정책 구조 및 모범 사례](./03-policy-structure.md)
- [Kiro Spec 기반 개발 프로세스](../02-kiro-features/01-spec-development.md)

## 추가 리소스

- [Terraform Plan JSON 형식](https://www.terraform.io/docs/internals/json-format.html)
- [Sentinel tfplan 모듈](https://docs.hashicorp.com/sentinel/imports/tfplan-v2)
- [Sentinel tfconfig 모듈](https://docs.hashicorp.com/sentinel/imports/tfconfig-v2)
- [Sentinel tfstate 모듈](https://docs.hashicorp.com/sentinel/imports/tfstate-v2)