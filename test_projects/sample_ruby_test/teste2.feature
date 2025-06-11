Feature: E-commerce B2B

  Scenario: Solicitação de cotação para pedido em grande volume
    Given que o cliente B2B está autenticado
    And o cliente seleciona 100 unidades do produto "Parafuso de Aço"
    When o cliente envia solicitação de cotação
    Then deve ser gerada uma proposta com preço unitário especial
    And o cliente recebe confirmação de recebimento da cotação

  Scenario: Pedido em massa com desconto aplicado
    Given que o cliente B2B adicionou 500 unidades do produto "Placa de Circuito" ao carrinho
    When o cliente finaliza o pedido
    Then o sistema aplica automaticamente o desconto de 10%
    And o valor total reflete o desconto