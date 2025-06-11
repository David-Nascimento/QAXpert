Feature: Autenticação de usuário

  Background:
    * url 'https://api.exemplo.com'
    * def credenciaisValidas = { username: 'admin', password: '123456' }
    * def credenciaisInvalidas = { username: 'admin', password: 'errado' }

  Scenario: Login com sucesso
    Given path '/login'
    And request credenciaisValidas
    When method post
    Then status 200
    And match response.message == 'Login realizado com sucesso'
    And match response.token != null

  Scenario: Login com senha incorreta
    Given path '/login'
    And request credenciaisInvalidas
    When method post
    Then status 401
    And match response.error == 'Credenciais inválidas'

  Scenario: Login sem preencher usuário
    Given path '/login'
    And request { password: '123456' }
    When method post
    Then status 400
    And match response.error contains 'usuário é obrigatório'
