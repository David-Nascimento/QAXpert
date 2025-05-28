require_relative 'env'

module QAxpert
  # Módulo principal da aplicação
  def self.run(repo_path:, lang:, output_path:, ai_provider: :openai)
    QAxpert::Core::Analyzer.new(lang).analyze(repo_path, output_path, ai_provider)
  end
end

