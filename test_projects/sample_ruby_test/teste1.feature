Feature: E-commerce Marketplace

  Scenario: Venda de produto por vendedor registrado
    Given que o vendedor está autenticado no marketplace
    When o vendedor cadastra um novo produto com título, descrição e preço
    Then o produto fica disponível para compra na loja

  Scenario: Compra de produto de múltiplos vendedores
    Given que o comprador autenticado adicionou itens de dois vendedores diferentes ao carrinho
    When o comprador realiza o checkout
    Then o pedido é criado como sub-pedidos separados para cada vendedor
    And o comprador recebe confirmação individual de cada vendedor
