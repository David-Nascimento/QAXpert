require 'rspec'
require_relative '../lib/qaxpert/Utils/t/quality_scorer'

describe Qaxpert::QualityScorer do
  describe '.score_feature' do
    it 'retorna pontuação alta para um feature bem estruturado' do
      feature = <<~FEATURE
        @login
        Feature: Login de usuário

          Scenario: Login com sucesso
            Given o usuário está na tela de login
            When informa email e senha válidos
            Then é redirecionado para a home
      FEATURE

      result = described_class.score_feature(feature)

      expect(result[:score]).to be >= 4.0
      expect(result[:feedback]).to include("Excelente")
    end

    it 'retorna pontuação baixa para feature sem keywords válidas' do
      ruim = <<~TXT
        Login sem estrutura
        Usuário entra
        Digita algo
        Sistema faz login
      TXT

      result = described_class.score_feature(ruim)

      expect(result[:score]).to be <= 1.5
      expect(result[:feedback]).to include("Fraco")
    end

    it 'detecta duplicação e penaliza' do
      duplicado = <<~FEATURE
        Feature: Teste duplicado

          Scenario: Cenário duplicado
            Given faço algo
            Given faço algo
            When continuo
            Then finalizo
      FEATURE

      result = described_class.score_feature(duplicado)

      expect(result[:score]).to be < 4.5
      expect(result[:feedback]).to match(/(Bom|Regular|Fraco)/)
    end
  end
end
