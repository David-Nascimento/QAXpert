module QAxpert
  module Core
    class LLMClient
      def self.call(prompt, provider: :openai)
        case provider
        when :openai
          call_openai(prompt)
        when :gemini
          QAxpert::GeminiClient.call(prompt) # <- usa seu cliente real
        else
          raise "Provedor de IA não suportado: #{provider}"
        end
      end

      def self.call_openai(prompt)
        api_key = ENV['OPENAI_API_KEY']
        uri = URI("https://api.openai.com/v1/chat/completions")

        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{api_key}"
        }

        body = {
          model: "gpt-4",
          messages: [
            { role: "system", content: "Você é um especialista em QA" },
            { role: "user", content: prompt }
          ]
        }.to_json

        response = Net::HTTP.post(uri, body, headers)
        result = JSON.parse(response.body)
        result.dig("choices", 0, "message", "content") || "[QAXpert] Sem resposta da IA"
      rescue => e
        "[QAXpert] Erro na chamada OpenAI: #{e.message}"
      end
    end
  end
end