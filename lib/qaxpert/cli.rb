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
        puts suggestion

        Utils.save_feature_file(path, suggestion)
      else
        puts "Uso: qaxpert analyze path/to/file"
      end
    end
  end
end