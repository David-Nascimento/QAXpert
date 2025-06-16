module QAxpert
  module Core
    class LLMClient
      #
      # Chama o provedor de IA especificado (:openai ou :gemini) com o prompt fornecido.
      #
      # @param prompt [String] Texto de entrada para a IA
      # @param provider [Symbol] :openai ou :gemini
      # @return [String] Resposta gerada pela IA ou mensagem de erro
      #
      def self.call(prompt, provider: :openai)
        case provider
        when :openai
          QAxpert::Clients::OpenAIClient.call(prompt)
        when :gemini
          QAxpert::Clients::GeminiClient.call(prompt)
        else
          raise "Provedor de IA não suportado: #{provider.inspect}"
        end
      end
    end
  end
end
