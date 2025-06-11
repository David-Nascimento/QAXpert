# QAxpert::CLI
#
# Classe responsável por processar os comandos da interface de linha de comando (CLI) do QAxpert.
#
# Comandos disponíveis:
# - analyze <caminho_para_arquivo>: Gera sugestões de cenários BDD para um arquivo de teste informado.
# - analyze-git: Gera sugestões de cenários BDD para todos os arquivos alterados no repositório Git atual.
# - analyze-coverage: Analisa o relatório de cobertura de testes e sugere cenários BDD para trechos com baixa cobertura.
# - score <caminho_para_feature>: Avalia a qualidade de um arquivo de feature e exibe uma pontuação e feedback.
#
# Métodos principais:
# - .run(args): Executa o comando informado pelo usuário, exibindo ajuda ou delegando para o método correspondente.
#
# Métodos privados:
# - .analyze_file(args): Analisa um arquivo de teste e gera sugestões de cenários BDD.
# - .analyze_git: Analisa arquivos alterados no Git e gera sugestões de cenários BDD.
# - .analyze_coverage: Analisa o relatório de cobertura e gera sugestões de cenários BDD para lacunas encontradas.
# - .score_feature(args): Avalia a qualidade de um arquivo de feature e exibe pontuação e feedback.
#
# Constantes:
# - USAGE: Texto de uso geral da ferramenta, exibido ao solicitar ajuda.
# - DESCRIPTIONS: Hash com descrições detalhadas de cada comando.
#
# Exemplos de uso:
#   qaxpert analyze features/user_spec.rb
#   qaxpert analyze-git
#   qaxpert analyze-coverage
#   qaxpert score features/user_signup.feature
module QAxpert
  class CLI
    USAGE = <<~USAGE.freeze
      Uso: qaxpert <comando> [opções]

      Comandos disponíveis:
        analyze <caminho_para_arquivo>      - Gera cenários BDD a partir de um arquivo específico.
        analyze-git                         - Gera cenários BDD para todos os arquivos alterados no Git.
        analyze-coverage                    - Gera cenários BDD com base em trechos de código com baixa cobertura.
        score <caminho_para_feature>        - Avalia a qualidade de um arquivo de feature e exibe pontuação.

      Exemplos:
        qaxpert analyze features/user_spec.rb
        qaxpert analyze-git
        qaxpert analyze-coverage
        qaxpert score features/user_signup.feature

      Use "qaxpert help <comando>" para ver mais detalhes sobre um comando específico.
    USAGE

    DESCRIPTIONS = {
      'analyze' => <<~DESC,
        analyze <caminho_para_arquivo>
          - Gera sugestões de cenários BDD para o arquivo informado.
          - O arquivo deve conter código de teste (RSpec, Cucumber, etc.).
          - O arquivo de saída será gerado no mesmo diretório, com sufixo `.suggestion.feature`.
      DESC

      'analyze-git' => <<~DESC,
        analyze-git
          - Detecta todos os arquivos alterados no repositório Git atual.
          - Para cada arquivo alterado, gera sugestões de cenários BDD.
          - Os arquivos de saída serão salvos ao lado dos originais, com sufixo `.suggestion.feature`.
      DESC

      'analyze-coverage' => <<~DESC,
        analyze-coverage
          - Carrega o relatório de cobertura gerado (por padrão, `coverage/coverage.json` ou similar).
          - Identifica trechos de código com baixa cobertura.
          - Gera sugestões de cenários BDD para cobrir essas lacunas.
          - O arquivo de saída será `low_coverage_analysis.suggestion.feature`.
      DESC

      'score' => <<~DESC
        score <caminho_para_feature>
          - Avalia a qualidade de um arquivo de feature existente.
          - Exibe pontuação (0.0 a 5.0) e feedback sobre estrutura, tags e boas práticas.
      DESC
    }.freeze

    def self.run(args)
      if args.empty? || args.first == 'help'
        command = args[1]
        if command && DESCRIPTIONS.key?(command)
          puts DESCRIPTIONS[command]
        else
          puts USAGE
        end
        exit(0)
      end

      command = args.shift

      case command
      when 'analyze'
        analyze_file(args)
      when 'analyze-git'
        analyze_git
      when 'analyze-coverage'
        analyze_coverage
      when 'score'
        score_feature(args)
      else
        puts "❌ Comando desconhecido: '#{command}'\n\n"
        puts USAGE
        exit(1)
      end
    end

    private_class_method def self.analyze_file(args)
      if args.empty?
        puts "❌ O comando 'analyze' requer o caminho para o arquivo de teste.\n\n"
        puts DESCRIPTIONS['analyze']
        exit(1)
      end

      path = args.first
      unless File.exist?(path)
        puts "❌ Arquivo não encontrado: #{path}"
        exit(1)
      end

      puts "📂 Analisando arquivo: #{path}"
      code = Parser.read_file(path)
      context = Parser.extract_context(code)
      suggestion = AIGenerator.generate_scenarios(context)

      puts "\n🧪 Sugestões de cenários BDD:\n\n"
      puts suggestion

      Utils.save_feature_file(path, suggestion)
      puts "\n✅ Arquivo de sugestões gerado: #{Utils.suggestion_path(path)}"
    end

    private_class_method def self.analyze_git
      changed = GitAnalyzer.changed_files
      if changed.empty?
        puts 'ℹ️  Nenhuma alteração detectada no repositório Git.'
        exit(0)
      end

      changed.each do |file|
        puts "📁 Alterado: #{file}"
        unless File.exist?(file)
          puts "   ❌ Arquivo removido ou não encontrado: #{file}"
          next
        end

        code = Parser.read_file(file)
        context = Parser.extract_context(code)
        suggestions = AIGenerator.generate_scenarios(context)

        puts "🧪 Sugestões para #{file}:\n\n"
        puts suggestions

        Utils.save_feature_file(file, suggestions)
        puts "   ✅ Sugestões salvas em: #{Utils.suggestion_path(file)}\n\n"
      end
    end

    private_class_method def self.analyze_coverage
      puts '📊 Analisando relatório de cobertura...'
      report = CoverageAnalyzer.load_coverage

      if report.start_with?('❌')
        puts report
        exit(1)
      end

      puts "🔍 Trechos com baixa cobertura identificados. Gerando sugestões...\n\n"
      suggestions = AIGenerator.generate_scenarios(report)

      puts "🧪 Sugestões da IA:\n\n"
      puts suggestions

      filename = 'low_coverage_analysis.suggestion.feature'
      Utils.save_feature_file(filename, suggestions, base_dir: Dir.pwd)
      puts "\n✅ Arquivo de sugestões gerado: #{filename}"
    end

    private_class_method def self.score_feature(args)
      if args.empty?
        puts "❌ O comando 'score' requer o caminho para o arquivo de feature.\n\n"
        puts DESCRIPTIONS['score']
        exit(1)
      end

      path = args.first
      unless File.exist?(path)
        puts "❌ Arquivo não encontrado: #{path}"
        exit(1)
      end

      content = File.read(path)
      result = QAxpert::QualityScorer.score_feature(content)

      puts "📊 Avaliação de Qualidade do Teste:\n\n"
      puts "Pontuação: #{format('%.1f', result[:score])}/5.0"
      puts "Feedback:\n#{result[:feedback]}"
    end
  end
end
