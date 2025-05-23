module Qaxpert
  class GeminiClient
    GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'

    def self.call(prompt)
      api_key = ENV['GEMINI_API_KEY']
      return "❌ Chave da API não encontrada." unless api_key

      uri = URI("#{GEMINI_API_URL}?key=#{api_key}")
      headers = { 'Content-Type' => 'application/json' }
      body = {
        contents: [
          {
            parts: [{ text: prompt }],
            role: 'user'
          }
        ]
      }.to_json

      response = Net::HTTP.post(uri, body, headers)

      json = JSON.parse(response.body)
      candidate = json.dig('candidates', 0, 'content', 'parts', 0, 'text')

      candidate || "❌ Resposta inválida da API Gemini."
    rescue => e
      "❌ Erro ao chamar Gemini: #{e.message}"
    end
  end
end
