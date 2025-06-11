module QAxpert
  class AIGenerator
    #
    # Gera cenários BDD a partir do contexto fornecido, usando o provedor de IA
    # definido em @default_provider. Por padrão, usa :openai, mas você pode
    # sobrescrever o provider passando :gemini (ou outro que implementar).
    #
    # @param context [String] Código ou dados de entrada para gerar os cenários
    # @param provider [Symbol] :openai ou :gemini
    # @return [String] Cenários BDD sugeridos ou mensagem de erro
    #
    @default_provider = :openai

    # Classe responsável por gerar cenários BDD a partir de um contexto fornecido,
    # utilizando um provedor de IA configurável.
    #
    # Métodos de Classe:
    #
    # - default_provider: Atributo acessor para definir ou obter o provedor padrão de IA.
    #
    # - generate_scenarios(context, provider: @default_provider):
    #     Gera cenários BDD no formato Gherkin com base no contexto informado.
    #     Utiliza um prompt especializado para solicitar sugestões a um cliente LLM.
    #     Parâmetros:
    #       - context: String contendo o código ou descrição base para geração dos cenários.
    #       - provider: (Opcional) Provedor de IA a ser utilizado. Padrão: @default_provider.
    #     Retorna:
    #       - String com os cenários gerados em formato Gherkin ou mensagem de erro caso não haja sugestão.
    class << self
      attr_accessor :default_provider

      def generate_scenarios(context, provider: @default_provider)
        prompt = <<~PROMPT
          Você é um assistente especializado em testes automatizados e geração de cenários BDD.
          Gere cenários adequados com base neste contexto de código/descrição:

          #{context}

          Formato de saída esperado: Gherkin (Feature, Scenario, Given/When/Then).
        PROMPT

        response = QAxpert::Core::LLMClient.call(prompt, provider: provider)
        response || '❌ Nenhuma sugestão gerada.'
      end
    end
  end
end
