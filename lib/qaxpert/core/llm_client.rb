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
          call_openai(prompt)
        when :gemini
          # Delegamos ao cliente Gemini, que deve existir em outro arquivo:
          QAxpert::GeminiClient.call(prompt)
        else
          raise "Provedor de IA não suportado: #{provider.inspect}"
        end
      end

      #
      # Realiza a chamada HTTP para a API OpenAI (Chat Completions) usando GPT-4.
      #
      # @param prompt [String]
      # @return [String]
      #
      def self.call_openai(prompt)
        api_key = ENV['OPENAI_API_KEY']
        return '[QAxpert] Erro: variável de ambiente OPENAI_API_KEY não definida.' unless api_key && !api_key.empty?

        uri = URI('https://api.openai.com/v1/chat/completions')
        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{api_key}"
        }

        body = {
          model: 'gpt-4',
          messages: [
            { role: 'system', content: 'Você é um especialista em QA' },
            { role: 'user', content: prompt }
          ]
        }.to_json

        response = Net::HTTP.post(uri, body, headers)
        result = JSON.parse(response.body)

        # Extrai o texto gerado
        result.dig('choices', 0, 'message', 'content') || '[QAxpert] Sem resposta válida da IA'
      rescue StandardError => e
        "[QAxpert] Erro na chamada OpenAI: #{e.message}"
      end
    end
  end
end
