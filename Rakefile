require 'rake'
require_relative 'lib/qaxpert'

# Exemplo de uso:
#   rake analyze TYPE=cucumber PATH=features AI=openai
#   rake test
#   rake build

desc 'Analisa o projeto. Variáveis de ambiente: TYPE, PATH, AI'
task :analyze do
  type = ENV.fetch('TYPE', nil) or raise 'Por favor informe TYPE (ex: cucumber, junit, robot)'
  path = ENV.fetch('FEATURE_PATH', nil) or raise 'Por favor informe PATH para os testes'
  ai   = ENV.fetch('AI', nil)   or raise 'Por favor informe AI (openai ou gemini)'

  output = File.join('qaxpert_output', type)
  FileUtils.rm_rf(output)
  FileUtils.mkdir_p(output)

  puts "[QAxpert] Iniciando análise: type=#{type}, path=#{path}, ai=#{ai}"
  analyzer = QAxpert::Core::Analyzer.new(type.to_sym)
  files = analyzer.analyze(path, output, ai.to_sym)
  puts "[QAxpert] Análise concluída: #{files.count} arquivos processados. Saída em: #{output}"
end
