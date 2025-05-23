module Qaxpert
  class CLI
    def self.run(args)
      if args[0] == 'analyze' && args[1]
        path = args[1]
        puts "📂 Analisando arquivo: #{path}"

        code = Parser.read_file(path)
        context = Parser.extract_context(code)
        suggestion = AIGenerator.generate_scenarios(context)

        puts("\n🧪 Sugestões de cenários BDD:\n")

        Utils.save_feature_file(path, suggestion)
      elsif args[0] == 'analyze-git'
        files = GitAnalyzer.changed_files
        files.each do |file|
          puts "📁 Alterado: #{file}"
          code = Parser.read_file(file)
          context = Parser.extract_context(code)
          suggestions = AIGenerator.generate_scenarios(context)
          puts "🧪 Sugestões para #{file}:"
          puts suggestions
          Utils.save_feature_file(file, suggestions)
        end
      elsif args[0] == 'analyze-jira'
        issue = GitUtils.current_issue_key
        if issue
          puts "🔎 Buscando dados da issue: #{issue}"
          data = Qaxpert::Integrations::JiraClient.fetch_issue(issue)
          suggestions = AIGenerator.generate_scenarios(data)
          puts "\n🧪 Sugestões com base na issue #{issue}:\n"
          puts suggestions
          Utils.save_feature_file(issue, suggestions)
        else
          puts "❌ Não foi possível detectar o ID da issue a partir da branch."
        end
      elsif args[0] == 'analyze-coverage'
        puts "📊 Analisando relatório de cobertura..."
        report = Qaxpert::CoverageAnalyzer.load_coverage
        if report.start_with?('❌')
          puts report
        else
          puts "🔍 Trechos com baixa cobertura identificados. Gerando sugestões...\n\n"
          suggestions = Qaxpert::AIGenerator.generate_scenarios(report)
          puts "🧪 Sugestões da IA:\n\n"
          puts suggestions
          Qaxpert::Utils.save_feature_file("low_coverage_analysis", suggestions)
        end
      elsif args[0] == 'score' && args[1]
        path = args[1]
        if File.exist?(path)
          content = File.read(path)
          result = Qaxpert::QualityScorer.score_feature(content)
          puts "📊 Avaliação de Qualidade do Teste:\n\n"
          puts "Pontuação: #{result[:score]}/5.0"
          puts "Feedback: #{result[:feedback]}"
        else
          puts "❌ Arquivo #{path} não encontrado."
        end
      end
    end
  end
end