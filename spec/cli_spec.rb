require 'rspec'
require 'fileutils'
require_relative '../lib/qaxpert/cli'
require_relative '../lib/qaxpert/Utils/utils'

module Qaxpert
  class GeminiClient
    def self.call(prompt)
      "Feature: Cenário gerado\n\n  Scenario: Execução via CLI\n    Given faço algo\n    When executo algo\n    Then vejo resultado"
    end
  end
end

describe Qaxpert::CLI do
  let(:temp_file) { 'spec/tmp_test_file.rb' }

  before do
    FileUtils.mkdir_p('spec')
    File.write(temp_file, "class Teste\n  def exemplo\n    puts 'teste'\n  end\nend")
  end

  after do
    File.delete(temp_file) if File.exist?(temp_file)
    FileUtils.rm_f('features/tmp_test_file.feature')
  end

  it 'executa CLI e salva feature gerada' do
    expect {
      Qaxpert::CLI.run(['analyze', temp_file])
    }.to output(/📂 Analisando arquivo/).to_stdout

    expect(File).to exist('features/tmp_test_file.feature')
    conteudo = File.read('features/tmp_test_file.feature')
    expect(conteudo).to include('Feature: Cenário gerado')
  end
end