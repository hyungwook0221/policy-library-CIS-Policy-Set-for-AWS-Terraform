# {{POLICY_NAME}} 테스트 케이스
# 설명: {{TEST_DESCRIPTION}}

test "{{TEST_NAME}}" {
    rules = {
        main = {{EXPECTED_RESULT}}
        {{#ADDITIONAL_RULES}}
        {{RULE_NAME}} = {{RULE_EXPECTED_RESULT}}
        {{/ADDITIONAL_RULES}}
    }
    
    {{#MOCK_DATA}}
    mock "{{MOCK_TYPE}}" {
        module {
            source = "{{MOCK_SOURCE}}"
        }
        
        data = {{MOCK_DATA_CONTENT}}
    }
    {{/MOCK_DATA}}
    
    {{#PARAMETERS}}
    param "{{PARAMETER_NAME}}" {
        value = {{PARAMETER_VALUE}}
    }
    {{/PARAMETERS}}
}