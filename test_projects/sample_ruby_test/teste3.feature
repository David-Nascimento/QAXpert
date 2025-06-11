Feature: E-commerce B2C

  Scenario: Compra de produto unitário com estoque disponível
    Given que o usuário está na página do produto "Tênis Esportivo"
    And o produto tem estoque disponível
    When o usuário adiciona o produto ao carrinho
    And o usuário prossegue para checkout
    And o usuário informa dados de pagamento válidos
    Then o pedido é confirmado
    And o usuário vê a mensagem "Pedido realizado com sucesso"

  Scenario: Busca de produto existente
    Given que o usuário está na página inicial do e-commerce
    When o usuário busca pelo termo "Camiseta"
    Then a lista de resultados inclui apenas produtos cujo nome contenha "Camiseta"