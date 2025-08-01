#!/usr/bin/env python3
"""
AWS CIS Sentinel 정책 메시지를 한글로 변경하는 스크립트
"""

import os
import re
import glob

# 메시지 번역 매핑
MESSAGE_TRANSLATIONS = {
    # 일반적인 패턴들
    "must be set to true": "true로 설정되어야 합니다",
    "must be set to false": "false로 설정되어야 합니다", 
    "must be present": "있어야 합니다",
    "must be greater than or equal to": "이상이어야 합니다",
    "must be less than or equal to": "이하여야 합니다",
    "should not allow": "허용해서는 안 됩니다",
    "should require": "요구해야 합니다",
    "should have": "가져야 합니다",
    "should be enabled": "활성화되어야 합니다",
    "should be disabled": "비활성화되어야 합니다",
    "is not compliant": "규정을 준수하지 않습니다",
    "are not compliant": "규정을 준수하지 않습니다",
    "Refer to": "자세한 내용은",
    "for more details": "을 참조하세요",
    "resources": "리소스",
    "Attribute": "속성",
    "with value": "값",
    
    # 특정 서비스 관련
    "S3 general purpose buckets": "S3 범용 버킷",
    "S3 buckets": "S3 버킷",
    "EBS volumes": "EBS 볼륨",
    "EC2 instances": "EC2 인스턴스",
    "IAM users": "IAM 사용자",
    "IAM policies": "IAM 정책",
    "CloudTrail": "CloudTrail",
    "VPC": "VPC",
    "Security Group": "보안 그룹",
    "Network ACL": "네트워크 ACL",
    "encryption": "암호화",
    "enabled": "활성화됨",
    "disabled": "비활성화됨",
    "public access": "퍼블릭 액세스",
    "ingress traffic": "인그레스 트래픽",
    "egress traffic": "이그레스 트래픽",
    "password policy": "패스워드 정책",
    "minimum password length": "최소 패스워드 길이",
    "password expiry": "패스워드 만료",
    "MFA delete": "MFA 삭제",
    "SSL": "SSL",
    "logging": "로깅",
    "flow logging": "플로우 로깅",
    "access logging": "액세스 로깅",
    "server-side encryption": "서버 측 암호화",
    "at-rest encryption": "저장 시 암호화",
    "key rotation": "키 로테이션",
    "public": "퍼블릭",
    "private": "프라이빗",
    "block": "차단",
    "allow": "허용",
    "deny": "거부",
    "policy": "정책",
    "bucket": "버킷",
    "volume": "볼륨",
    "instance": "인스턴스",
    "user": "사용자",
    "group": "그룹",
    "role": "역할",
    "days": "일",
    "port": "포트",
}

def translate_message(message):
    """메시지를 한글로 번역"""
    translated = message
    
    # 특정 패턴들을 먼저 처리
    patterns = [
        (r"Attribute '([^']+)' must be set to true for '([^']+)' resources", 
         r"'\2' 리소스의 '\1' 속성은 true로 설정되어야 합니다"),
        (r"Attribute '([^']+)' must be present for '([^']+)' resources", 
         r"'\2' 리소스에는 '\1' 속성이 있어야 합니다"),
        (r"Attribute '([^']+)' with value ([0-9]+) must be greater than or equal to ([0-9]+) for '([^']+)' resources", 
         r"'\4' 리소스의 '\1' 속성 값 \2은(는) \3 이상이어야 합니다"),
        (r"Attribute '([^']+)' with value ([0-9]+) must be less than or equal to ([0-9]+) days for '([^']+)' resources", 
         r"'\4' 리소스의 '\1' 속성 값 \2은(는) \3일 이하여야 합니다"),
        (r"Attribute '([^']+)' must be greater than or equal to ([0-9]+) for '([^']+)' resources", 
         r"'\3' 리소스의 '\1' 속성은 \2 이상이어야 합니다"),
        (r"Attribute '([^']+)' must be less than or equal to ([0-9]+) days for '([^']+)' resources", 
         r"'\3' 리소스의 '\1' 속성은 \2일 이하여야 합니다"),
    ]
    
    for pattern, replacement in patterns:
        translated = re.sub(pattern, replacement, translated)
    
    # 일반적인 단어/구문 번역
    for eng, kor in MESSAGE_TRANSLATIONS.items():
        translated = translated.replace(eng, kor)
    
    # URL 뒤에 한글 추가
    translated = re.sub(r'(https://[^\s]+)', r'\1 를', translated)
    
    return translated

def update_sentinel_file(filepath):
    """Sentinel 파일의 메시지를 한글로 업데이트"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 메시지 상수 패턴 찾기 및 번역
        message_patterns = [
            r'"message":\s*"([^"]+)"',
            r'"([^"]*violation[^"]*message[^"]*)": "([^"]+)"',
            r'"([^"]*_message[^"]*)": "([^"]+)"',
        ]
        
        for pattern in message_patterns:
            matches = re.finditer(pattern, content)
            for match in matches:
                if len(match.groups()) == 1:
                    # "message": "..." 패턴
                    original_msg = match.group(1)
                    translated_msg = translate_message(original_msg)
                    content = content.replace(f'"{original_msg}"', f'"{translated_msg}"')
                else:
                    # 다른 메시지 상수 패턴
                    key = match.group(1)
                    original_msg = match.group(2)
                    translated_msg = translate_message(original_msg)
                    content = content.replace(f'"{key}": "{original_msg}"', f'"{key}": "{translated_msg}"')
        
        # 함수 내 문자열 리터럴 번역
        function_string_patterns = [
            r'return "([^"]+)"',
        ]
        
        for pattern in function_string_patterns:
            matches = re.finditer(pattern, content)
            for match in matches:
                original_msg = match.group(1)
                if any(keyword in original_msg.lower() for keyword in ['attribute', 'must', 'should', 'refer to']):
                    translated_msg = translate_message(original_msg)
                    content = content.replace(f'return "{original_msg}"', f'return "{translated_msg}"')
        
        # 변경사항이 있으면 파일 저장
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated: {filepath}")
            return True
        else:
            print(f"No changes: {filepath}")
            return False
            
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """메인 함수"""
    print("AWS CIS Sentinel 정책 메시지 한글화 시작...")
    
    # policies 디렉터리의 모든 .sentinel 파일 찾기
    sentinel_files = glob.glob("policies/**/*.sentinel", recursive=True)
    
    updated_count = 0
    total_count = len(sentinel_files)
    
    for filepath in sentinel_files:
        if update_sentinel_file(filepath):
            updated_count += 1
    
    print(f"\n완료: {total_count}개 파일 중 {updated_count}개 파일이 업데이트되었습니다.")

if __name__ == "__main__":
    main()