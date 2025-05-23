require 'net/http'
require 'json'
require 'dotenv/load'

module Qaxpert
  class AIGenerator
    def self.generate_scenarios(context)
      prompt = "Gere cenários BDD baseados neste código: \n#{context}"
      response = call_gemini_api(prompt)
      response || "❌ Nenhuma sugestão gerada."
    end

    def self.call_gemini_api(prompt)
      api_key = ENV['GEMINI_API_KEY']
      return "❌ API key não encontrada." unless api_key

      # Aqui você pode substituir por uma chamada real à Gemini (placeholder)
      # Por enquanto vamos simular uma resposta simples
      "Feature: Login\n\n  Scenario: Acesso com sucesso\n    Given estou na tela de login\n    When digito e-mail e senha válidos\n    Then sou redirecionado para a home"
    end
  end
end