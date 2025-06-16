require_relative 'llm_client_interface'

module QAxpert
  module Clients
    class OpenAIClient
      include LLMClientInterface

      #
      # @param api_key [String] chave da OpenAI (ENV['OPENAI_API_KEY'])
      #
      def initialize(api_key: ENV.fetch('OPENAI_API_KEY', nil))
        @api_key = api_key
        return if @api_key && !@api_key.empty?

        raise 'OPENAI_API_KEY não definida'
      end

      #
      # Chama a API de Chat Completions da OpenAI usando GPT-4.
      #
      # @param prompt [String]
      # @return [String] texto gerado pelo modelo
      #
      def call(prompt)
        uri = URI('https://api.openai.com/v1/chat/completions')
        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@api_key}"
        }

        body = {
          model: 'gpt-4',
          messages: [
            { role: 'system', content: 'Você é um especialista em QA.' },
            { role: 'user',   content: prompt }
          ]
        }.to_json

        response = Net::HTTP.post(uri, body, headers)
        result   = JSON.parse(response.body)
        result.dig('choices', 0, 'message', 'content') || '[QAxpert] Sem resposta válida da OpenAI'
      rescue StandardError => e
        "[QAxpert] Erro na chamada OpenAI: #{e.message}"
      end
    end
  end
end
