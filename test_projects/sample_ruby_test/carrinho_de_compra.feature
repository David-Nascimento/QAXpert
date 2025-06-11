Feature: Login de Usuário

  Scenario: Tentativa de login com credenciais válidas
    Given que o usuário está na página de login
    When o usuário insere "usuario_valido" no campo "nome de usuário"
    And o usuário insere "senha_valida" no campo "senha"
    And o usuário clica no botão "Entrar"
    Then o usuário deve ser redirecionado para o painel principal

  Scenario: Tentativa de login com nome de usuário inválido
    Given que o usuário está na página de login
    When o usuário insere "usuario_invalido" no campo "nome de usuário"
    And o usuário insere "senha_qualquer" no campo "senha"
    And o usuário clica no botão "Entrar"
    Then o usuário deve ver a mensagem de erro "Nome de usuário ou senha inválidos."

  Scenario: Tentativa de login com senha inválida
    Given que o usuário está na página de login
    When o usuário insere "usuario_valido" no campo "nome de usuário"
    And o usuário insere "senha_invalida" no campo "senha"
    And o usuário clica no botão "Entrar"
    Then o usuário deve ver a mensagem de erro "Nome de usuário ou senha inválidos."

  Scenario: Tentativa de login com campos vazios
    Given que o usuário está na página de login
    When o usuário insere "" no campo "nome de usuário"
    And o usuário insere "" no campo "senha"
    And o usuário clica no botão "Entrar"
    Then o usuário deve ver a mensagem de erro "Por favor, preencha todos os campos."