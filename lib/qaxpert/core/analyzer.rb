module QAxpert
  module Core
    class Analyzer
      def initialize(lang)
        @lang = lang
        @language_handler = case lang
                            when :ruby
                              QAxpert::Languages::Ruby.new
                            when :robot
                              QAxpert::Languages::Robot.new
                            when :karate
                              QAxpert::Languages::Karate.new
                            when :postman
                              QAxpert::Languages::Postman.new
                            when :rest
                              QAxpert::Languages::Rest.new
                            when :java
                              QAxpert::Languages::Java.new
                            when :flutter
                              QAxpert::Languages::Flutter.new
                            else
                              raise "Linguagem #{lang} não suportada"
                            end
      end

      def analyze(repo_path, output_path, ai_provider)
        puts "[QAXpert] Iniciando análise para linguagem: #{@lang.upcase}"
        puts "[QAXpert] Projeto: #{repo_path}"

        # Verifica se diretório de saída existe
        Dir.mkdir(output_path) unless Dir.exist?(output_path)

        # 1. Detectar arquivos de teste
        test_files = @language_handler.analyze(repo_path)
        puts "[QAXpert] Arquivos de teste detectados: #{test_files.count}"

        # 2. Obter diff do repositório
        diff = QAxpert::Core::GitHistory.extract_diff(repo_path)
        context = "Código analisado com histórico de testes e mudanças."

        # 3. Gerar prompt para LLM
        prompt = @language_handler.generate_prompt_for_test(diff, context)
        puts "\n[Prompt para IA]:\n#{prompt}"

        # 4. Salvar prompt para uso manual
        File.write(File.join(output_path, "prompt.txt"), prompt)
        puts "[QAXpert] Prompt salvo em: #{output_path}/prompt.txt"

        # 5. Enviar para IA (OpenAI ou Gemini)
        response = QAxpert::Core::LLMClient.call(prompt, provider: ai_provider)
        File.write(File.join(output_path, "response.txt"), response)
        puts "[QAXpert] Resposta da IA salva em: #{output_path}/response.txt"
      end
    end
  end
end