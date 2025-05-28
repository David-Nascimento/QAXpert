require 'rake'
require_relative './lib/qaxpert'

namespace :qaxpert do
  desc "Executa análise para o tipo de teste informado"
  task :analyze, [:type, :path, :output, :ai] do |t, args|
    args.with_defaults(
      path: Dir.pwd,
      output: './qaxpert_output',
      ai: 'openai'
    )

    puts "[QAXpert] Analisando tipo: #{args[:type]}"

    QAxpert.run(
      repo_path: args[:path],
      lang: args[:type].to_sym,
      output_path: args[:output],
      ai_provider: args[:ai].to_sym
    )
  end
end
