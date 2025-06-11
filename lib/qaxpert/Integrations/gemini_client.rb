# Classe responsável por integrar com a API Gemini.
# 
# Métodos:
# - self.call(prompt): Envia um prompt para a API Gemini e retorna a resposta.
#
# Constantes:
# - GEMINI_API_URL: URL base da API Gemini, obtida das variáveis de ambiente.
#
# Exceções:
# - Retorna mensagens de erro amigáveis caso a chave da API não seja encontrada,
#   a resposta da API seja inválida ou ocorra algum erro durante a chamada.
module QAxpert
  class GeminiClient
    GEMINI_API_URL = ENV['GEMINI_API_URL']

    def self.call(prompt)
      api_key = ENV['GEMINI_API_KEY']
      return '❌ Chave da API não encontrada.' unless api_key

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

      candidate || '❌ Resposta inválida da API Gemini.'
    rescue StandardError => e
      "❌ Erro ao chamar Gemini: #{e.message}"
    end
  end
end
