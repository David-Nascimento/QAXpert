module QAxpert
  # Módulo Core
  #
  # Este módulo contém classes e funcionalidades centrais do QAxpert,
  # incluindo a classe Analyzer, responsável por orquestrar o processo
  # de análise de repositórios de código-fonte utilizando diferentes
  # provedores de IA e linguagens suportadas.
  #
  # As principais responsabilidades deste módulo incluem:
  # - Inicialização de componentes de análise conforme a linguagem selecionada.
  # - Gerenciamento do fluxo de análise, incluindo suporte a dry-run.
  # - Integração com provedores de IA para análise automatizada de código.
  # - Propagação de opções como diff e verbose para os componentes internos.
  #
  # Classes principais:
  # - Analyzer: Classe responsável por executar a análise de código-fonte.
  module Core
    class Analyzer
      def initialize(lang)
        @lang = lang
      end

      #
      # @param repo_path   [String]
      # @param output_path [String]
      # @param ai_provider [Symbol]
      # @param diff        [String]
      # @param dry_run     [Boolean]
      # @param verbose     [Boolean]
      # @return [Array<String>]
      #
      def analyze(repo_path, output_path, ai_provider, diff: nil, dry_run: false, verbose: false)
        puts "[QAxpert] Iniciando análise: #{repo_path} (#{@lang.upcase})"
        FileUtils.mkdir_p(output_path)

        # Se dry_run, apenas lista arquivos e sai
        if dry_run
          patterns = QAxpert::Languages::LanguageHandler.load_config![@lang]['patterns']
          discoverer = QAxpert::Services::FileDiscoverer.new(repo_path: repo_path, patterns: patterns)
          files = discoverer.discover
          puts 'Arquivos que seriam analisados (dry-run):'
          files.each { |f| puts "  - #{f}" }
          return files
        end

        ai_client = case ai_provider
                    when :openai then QAxpert::Clients::OpenAIClient.new
                    when :gemini then QAxpert::Clients::GeminiClient.new
                    else raise "Provedor de IA não suportado: #{ai_provider.inspect}"
                    end

        handler = QAxpert::Languages::LanguageHandler.new(
          lang: @lang,
          repo_path: repo_path,
          output_base: output_path,
          ai_client: ai_client
        )

        # Se diff foi passado, define no handler
        handler.diff_override = diff if diff

        # Ajustar handler para receber verbose (precisaremos propagar)
        handler.verbose = true if handler.respond_to?(:verbose=) && handler.respond_to?(:verbose=) && verbose

        result = handler.analyze_all
        files = case result
                when Hash then result.values.flatten
                when Array then result
                else Array(result)
                end

        config = QAxpert::Languages::LanguageHandler.load_config![@lang.to_sym]
        output_path = config['output_base']
        puts "[QAxpert] Análise concluída (#{files.count} arquivos). Saída em: #{output_path}" if verbose
        files
      end
    end
  end
end
