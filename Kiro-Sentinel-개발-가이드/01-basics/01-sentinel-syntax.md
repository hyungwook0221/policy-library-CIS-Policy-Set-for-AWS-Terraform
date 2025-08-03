# Sentinel 문법 및 기본 개념

## 개요

Sentinel은 HashiCorp에서 개발한 정책 언어로, Terraform과 같은 인프라스트럭처 도구에 정책 기반 거버넌스를 제공합니다. 이 가이드에서는 Sentinel의 기본 문법과 핵심 개념을 학습합니다.

## 기본 문법

### 1. 주석 (Comments)

```sentinel
# 한 줄 주석
// 이것도 한 줄 주석

/*
여러 줄 주석
여러 줄에 걸쳐 작성 가능
*/
```

### 2. 데이터 타입 (Data Types)

#### 2.1 기본 타입

```sentinel
# 문자열 (String)
name = "AWS EC2 Instance"
description = '단일 따옴표도 사용 가능'

# 숫자 (Number)
max_instances = 10
cpu_threshold = 80.5

# 불린 (Boolean)
is_enabled = true
allow_public_access = false

# null 값
empty_value = null
```

#### 2.2 컬렉션 타입

```sentinel
# 리스트 (List)
allowed_regions = ["us-east-1", "us-west-2", "ap-northeast-2"]
instance_types = [
    "t3.micro",
    "t3.small",
    "t3.medium"
]

# 맵 (Map)
instance_limits = {
    "t3.micro": 10,
    "t3.small": 5,
    "t3.medium": 2
}

# 중첩된 구조
policy_config = {
    "name": "EC2 Instance Policy",
    "rules": [
        {
            "type": "instance_type",
            "allowed": ["t3.micro", "t3.small"]
        },
        {
            "type": "region",
            "allowed": ["us-east-1", "us-west-2"]
        }
    ]
}
```

### 3. 변수 (Variables)

```sentinel
# 변수 선언 및 할당
policy_name = "ec2-instance-validation"
max_cpu_cores = 4

# 변수 재할당
current_count = 0
current_count = current_count + 1

# 상수 (관례적으로 대문자 사용)
MAX_INSTANCES = 100
ALLOWED_REGIONS = ["us-east-1", "us-west-2"]
```

### 4. 연산자 (Operators)

#### 4.1 산술 연산자

```sentinel
# 기본 산술 연산
total = 10 + 5      # 15
difference = 10 - 3  # 7
product = 4 * 5     # 20
quotient = 20 / 4   # 5
remainder = 17 % 5  # 2

# 문자열 연결
full_name = "aws_" + "instance"  # "aws_instance"
```

#### 4.2 비교 연산자

```sentinel
# 동등성 비교
is_equal = (5 == 5)        # true
is_not_equal = (5 != 3)    # true

# 크기 비교
is_greater = (10 > 5)      # true
is_less = (3 < 8)          # true
is_greater_equal = (5 >= 5) # true
is_less_equal = (4 <= 6)   # true
```

#### 4.3 논리 연산자

```sentinel
# AND, OR, NOT
has_permission = true
is_admin = false

can_access = has_permission and is_admin     # false
can_view = has_permission or is_admin        # true
is_restricted = not has_permission           # false

# 복합 조건
is_valid_instance = (instance_type == "t3.micro") and 
                   (region in allowed_regions) and 
                   (not is_spot_instance)
```

#### 4.4 멤버십 연산자

```sentinel
# in 연산자 - 컬렉션 멤버십 확인
allowed_types = ["t3.micro", "t3.small", "t3.medium"]
is_allowed = "t3.micro" in allowed_types     # true

# contains 연산자 - 부분 문자열 확인
resource_name = "aws_instance.web_server"
is_instance = "instance" in resource_name   # true
```

### 5. 조건문 (Conditionals)

#### 5.1 if-else 문

```sentinel
# 기본 if-else
instance_type = "t3.large"

if instance_type in ["t3.micro", "t3.small"] {
    cost_category = "low"
} else if instance_type in ["t3.medium", "t3.large"] {
    cost_category = "medium"
} else {
    cost_category = "high"
}

# 삼항 연산자
status = is_compliant ? "통과" : "실패"
```

#### 5.2 조건부 표현식

```sentinel
# 조건부 할당
max_instances = environment == "production" ? 10 : 5

# 복합 조건
access_level = (is_admin and has_mfa) ? "full" : 
               (is_user and has_mfa) ? "limited" : "none"
```

### 6. 반복문 (Loops)

#### 6.1 for 루프

```sentinel
# 리스트 순회
instance_types = ["t3.micro", "t3.small", "t3.medium"]

for instance_types as index, type {
    print("인덱스", index, ":", type)
}

# 맵 순회
instance_limits = {
    "t3.micro": 10,
    "t3.small": 5,
    "t3.medium": 2
}

for instance_limits as type, limit {
    print("타입:", type, "제한:", limit)
}
```

#### 6.2 컬렉션 처리

```sentinel
# map 함수 - 각 요소 변환
numbers = [1, 2, 3, 4, 5]
doubled = map numbers as _, n {
    n * 2
}  # [2, 4, 6, 8, 10]

# filter 함수 - 조건에 맞는 요소만 선택
all_instances = [
    {"type": "t3.micro", "count": 5},
    {"type": "t3.large", "count": 2},
    {"type": "t3.small", "count": 3}
]

small_instances = filter all_instances as _, instance {
    instance.type in ["t3.micro", "t3.small"]
}
```

### 7. 함수 (Functions)

#### 7.1 함수 정의

```sentinel
# 기본 함수 정의
validate_instance_type = func(instance_type) {
    allowed_types = ["t3.micro", "t3.small", "t3.medium"]
    return instance_type in allowed_types
}

# 매개변수가 여러 개인 함수
calculate_cost = func(instance_type, hours, region) {
    base_rates = {
        "t3.micro": 0.0104,
        "t3.small": 0.0208,
        "t3.medium": 0.0416
    }
    
    region_multiplier = region == "us-east-1" ? 1.0 : 1.2
    base_rate = base_rates[instance_type]
    
    return base_rate * hours * region_multiplier
}

# 함수 호출
is_valid = validate_instance_type("t3.micro")  # true
monthly_cost = calculate_cost("t3.small", 720, "us-west-2")
```

#### 7.2 고급 함수 패턴

```sentinel
# 클로저 (Closure)
create_validator = func(allowed_values) {
    return func(value) {
        return value in allowed_values
    }
}

# 사용 예
instance_validator = create_validator(["t3.micro", "t3.small"])
is_valid_instance = instance_validator("t3.micro")  # true

# 재귀 함수
count_nested_resources = func(resources) {
    count = 0
    for resources as _, resource {
        count += 1
        if "children" in keys(resource) {
            count += count_nested_resources(resource.children)
        }
    }
    return count
}
```

### 8. 내장 함수 (Built-in Functions)

#### 8.1 문자열 함수

```sentinel
import "strings"

# 문자열 조작
resource_name = "aws_instance.web_server"
service_type = strings.split(resource_name, ".")[0]  # "aws_instance"
server_name = strings.split(resource_name, ".")[1]   # "web_server"

# 대소문자 변환
upper_name = strings.to_upper("hello")  # "HELLO"
lower_name = strings.to_lower("WORLD")  # "world"

# 문자열 검색 및 치환
contains_instance = strings.contains(resource_name, "instance")  # true
new_name = strings.replace(resource_name, "web", "app", -1)
```

#### 8.2 수학 함수

```sentinel
import "math"

# 수학 연산
max_value = math.max(10, 20, 5)    # 20
min_value = math.min(10, 20, 5)    # 5
absolute = math.abs(-15)           # 15
rounded = math.round(3.7)          # 4
```

#### 8.3 시간 함수

```sentinel
import "time"

# 현재 시간
current_time = time.now()
current_hour = time.hour(current_time)

# 시간 비교
creation_time = time.parse("2023-01-01T00:00:00Z")
is_recent = time.since(creation_time) < time.hour * 24  # 24시간 이내
```

### 9. 모듈 시스템 (Modules)

#### 9.1 모듈 임포트

```sentinel
# 표준 라이브러리 임포트
import "strings"
import "time"
import "math"

# 별칭 사용
import "strings" as str
import "collection/maps" as maps

# Terraform 관련 모듈
import "tfplan/v2" as tfplan
import "tfconfig/v2" as tfconfig
import "tfstate/v2" as tfstate
```

#### 9.2 사용자 정의 모듈

```sentinel
# helpers.sentinel 모듈
export = {
    "validate_instance_type": validate_instance_type,
    "calculate_cost": calculate_cost,
    "ALLOWED_TYPES": ["t3.micro", "t3.small", "t3.medium"]
}

validate_instance_type = func(instance_type) {
    return instance_type in ALLOWED_TYPES
}

# 메인 정책에서 사용
import "helpers" as helpers

is_valid = helpers.validate_instance_type("t3.micro")
allowed_types = helpers.ALLOWED_TYPES
```

### 10. 오류 처리 (Error Handling)

```sentinel
# null 체크
validate_resource = func(resource) {
    if resource is null {
        return {
            "valid": false,
            "error": "리소스가 null입니다"
        }
    }
    
    if "instance_type" not in keys(resource) {
        return {
            "valid": false,
            "error": "instance_type 속성이 없습니다"
        }
    }
    
    return {"valid": true}
}

# 안전한 속성 접근
get_instance_type = func(resource) {
    if resource is null or "values" not in keys(resource) {
        return "unknown"
    }
    
    values = resource.values
    if "instance_type" not in keys(values) {
        return "unknown"
    }
    
    return values.instance_type
}
```

## 실습 예제

### 예제 1: EC2 인스턴스 타입 검증

```sentinel
# EC2 인스턴스 타입 검증 정책
import "tfplan/v2" as tfplan

# 허용되는 인스턴스 타입 정의
allowed_instance_types = [
    "t3.micro",
    "t3.small", 
    "t3.medium"
]

# Terraform plan에서 EC2 인스턴스 리소스 추출
ec2_instances = filter tfplan.resource_changes as _, rc {
    rc.type == "aws_instance" and
    rc.mode == "managed" and
    rc.change.actions contains "create"
}

# 각 인스턴스의 타입 검증
violations = []
for ec2_instances as _, instance {
    instance_type = instance.change.after.instance_type
    
    if instance_type not in allowed_instance_types {
        violation = {
            "resource": instance.address,
            "type": instance_type,
            "message": "허용되지 않는 인스턴스 타입: " + instance_type
        }
        append(violations, violation)
    }
}

# 정책 규칙
main = rule {
    length(violations) == 0
}

# 위반 사항 출력
if length(violations) > 0 {
    print("=== 정책 위반 사항 ===")
    for violations as _, v {
        print("리소스:", v.resource)
        print("타입:", v.type)
        print("메시지:", v.message)
        print("---")
    }
}
```

### 예제 2: 태그 검증 정책

```sentinel
# 필수 태그 검증 정책
import "tfplan/v2" as tfplan

# 필수 태그 목록
required_tags = [
    "Environment",
    "Owner", 
    "Project",
    "CostCenter"
]

# 태그를 지원하는 리소스 타입
taggable_resources = [
    "aws_instance",
    "aws_s3_bucket",
    "aws_rds_instance",
    "aws_lambda_function"
]

# 태그 검증 함수
validate_tags = func(resource) {
    if "tags" not in keys(resource.change.after) {
        return {
            "valid": false,
            "missing_tags": required_tags
        }
    }
    
    resource_tags = resource.change.after.tags
    missing_tags = []
    
    for required_tags as _, tag {
        if tag not in keys(resource_tags) {
            append(missing_tags, tag)
        }
    }
    
    return {
        "valid": length(missing_tags) == 0,
        "missing_tags": missing_tags
    }
}

# 태그 가능한 리소스 필터링
resources_to_check = filter tfplan.resource_changes as _, rc {
    rc.type in taggable_resources and
    rc.mode == "managed" and
    rc.change.actions contains "create"
}

# 각 리소스의 태그 검증
tag_violations = []
for resources_to_check as _, resource {
    validation_result = validate_tags(resource)
    
    if not validation_result.valid {
        violation = {
            "resource": resource.address,
            "type": resource.type,
            "missing_tags": validation_result.missing_tags
        }
        append(tag_violations, violation)
    }
}

# 정책 규칙
main = rule {
    length(tag_violations) == 0
}
```

## 다음 단계

이제 Sentinel의 기본 문법을 익혔으니, 다음 가이드에서는 Terraform 데이터에 접근하는 방법을 학습하겠습니다:

- [Terraform 데이터 접근](./02-terraform-data-access.md)
- [정책 구조 및 모범 사례](./03-policy-structure.md)

## 추가 리소스

- [Sentinel 공식 문서](https://docs.hashicorp.com/sentinel/)
- [Sentinel 언어 명세](https://docs.hashicorp.com/sentinel/language/)
- [Terraform Sentinel 가이드](https://learn.hashicorp.com/tutorials/terraform/sentinel-intro)