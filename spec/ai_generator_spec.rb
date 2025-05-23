require 'rspec'
require_relative '../lib/qaxpert/ai_generator'

module Qaxpert
  class GeminiClient
    def self.call(prompt)
      "Feature: Teste mockado

  Scenario: Login com sucesso
    Given acesso a tela de login
    When preencho email e senha
    Then sou redirecionado"
    end
  end
end

describe Qaxpert::AIGenerator do
  describe '.generate_scenarios' do
    it 'retorna sugestão mockada de cenário BDD' do
      contexto = "Classe detectada: class SessionsController
Método: create"
      resultado = described_class.generate_scenarios(contexto)

      expect(resultado).to include('Feature:')
      expect(resultado).to include('Scenario:')
    end
  end
end