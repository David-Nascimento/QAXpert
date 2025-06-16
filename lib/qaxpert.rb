require_relative 'env'

module QAxpert
  class << self
    #
    # @param repo_path   [String]
    # @param lang        [Symbol] :ruby, :java, etc.
    # @param output_path [String]
    # @param ai_provider [Symbol]
    # @param from_ref    [String, nil]
    # @param to_ref      [String, nil]
    # @param dry_run     [Boolean]
    # @param verbose     [Boolean]
    #
    def run(repo_path:, lang:, output_path: './qaxpert_output', ai_provider: :openai, from_ref: nil, to_ref: nil,
            dry_run: false, verbose: false)
      abort("❌ O caminho do repositório não existe: #{repo_path}") unless repo_path && Dir.exist?(repo_path)

      supported = QAxpert::Languages::LanguageHandler.load_config!.keys
      unless supported.include?(lang)
        abort("❌ Tipo inválido: #{lang.inspect}. Use um dos valores: #{supported.join(', ')}")
      end

      FileUtils.mkdir_p(output_path)
      QAxpert::Core.ai_provider = ai_provider

      puts "🛠️  Iniciando análise para a stack #{lang.to_s.capitalize}..."
      analyzer = QAxpert::Core::Analyzer.new(lang)

      # Extrai diff real
      diff = QAxpert::Core::GitHistory.extract_diff(repo_path, from_ref: from_ref, to_ref: to_ref)

      # Passa diff, dry_run e verbose ao analyze
      analyzer.analyze(repo_path, output_path, ai_provider, diff: diff, dry_run: dry_run, verbose: verbose)
    end
  end

  # Carrega o arquivo de configuração do AI Provider
  module Core
    class << self
      attr_accessor :ai_provider
    end
  end
end
