require_relative 'llm_client_interface'
# require 'gemini_sdk'   # se existir um SDK, importe aqui

module QAxpert
  module Clients
    class GeminiClient
      include LLMClientInterface

      #
      # @param api_key [String] chave da Gemini (pode usar ENV['GEMINI_API_KEY'])
      #
      def initialize(api_key: ENV['GEMINI_API_KEY'])
        @api_key = api_key
        # Se houver validação específica, coloque aqui. Por ora, não obrigamos ter chave.
      end

      #
      # Chama de fato o método existente que você já possui para Gemini.
      #
      # @param prompt [String]
      # @return [String]
      #
      def call(prompt)
        # Aqui delegamos para o client que você já tinha registrado em QAxpert::GeminiClient.
        # Se sua classe original estava no namespace principal, referencie-a diretamente:
        QAxpert::GeminiClient.call(prompt)
      rescue StandardError => e
        "[QAxpert] Erro na chamada Gemini: #{e.message}"
      end
    end
  end
end
