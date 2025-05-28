*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Login With Valid Credentials
    Create Session    api    https://example.com
    ${response}=    POST    api    /api/login    json={"user":"admin","pass":"123"}
    Should Be Equal As Strings    ${response.status_code}    200

# test_projects/sample_karate_tests/login.feature
Feature: Login endpoint
  Scenario: Valid login
    Given url 'https://example.com/api/login'
    And request { user: 'admin', pass: '123' }
    When method post
    Then status 200
    And match response.message == 'success'