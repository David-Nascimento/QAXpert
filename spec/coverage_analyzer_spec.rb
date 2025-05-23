require 'rspec'
require 'json'
require_relative '../lib/qaxpert/coverage_analyzer'

describe Qaxpert::CoverageAnalyzer do
  let(:fake_path) { 'spec/fake_coverage.json' }

  before do
    fake_coverage = {
      "RSpec" => {
        "timestamp" => 123456789,
        "command_name" => "RSpec",
        "coverage" => {
          "/app/models/user.rb" => [1, 0, 0, nil, 1],
          "/app/controllers/session.rb" => [nil, 1, 0, 0, 1]
        }
      }
    }

    File.write(fake_path, fake_coverage.to_json)
  end

  after do
    File.delete(fake_path) if File.exist?(fake_path)
  end

  it 'carrega arquivos com linhas não cobertas' do
    output = described_class.load_coverage(fake_path)

    expect(output).to include("Arquivo: /app/models/user.rb")
    expect(output).to include("Linhas não cobertas: 2, 3")

    expect(output).to include("Arquivo: /app/controllers/session.rb")
    expect(output).to include("Linhas não cobertas: 3, 4")
  end

  it 'retorna mensagem de erro se arquivo não existir' do
    expect(Qaxpert::CoverageAnalyzer.load_coverage("inexistente.json")).to include("❌ Arquivo de cobertura não encontrado.")
  end
end
