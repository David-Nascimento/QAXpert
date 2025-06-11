module QAxpert
  module Clients
    #
    # Interface mínima para um client de IA: deve implementar `call(prompt)` e retornar string.
    #
    module LLMClientInterface
      # Gera uma resposta de IA para o prompt fornecido.
      #
      # @param prompt [String] texto de entrada para a IA
      # @return [String] resposta gerada
      #
      def call(prompt)
        raise NotImplementedError, "#{self.class} precisa implementar o método `call(prompt)`"
      end
    end
  end
end
