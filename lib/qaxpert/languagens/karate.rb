module QAxpert
  module Languages
    class Karate
      def analyze(repo_path)
        test_files = Dir.glob(File.join(repo_path, "**", "*.feature")).select do |file|
          File.read(file).include?("Feature:") && File.read(file).include?("Karate")
        end
        puts "[KARATE] Encontrados #{test_files.count} arquivos testes em Karate DSL"
        test_files
      end

      def generate_prompt_for_test(diff, context)
        <<~PROMPT
          Você é um especialista em testes automatizados com Karate DSL.
                    Avalie o seguinte cenário e sugira melhorias com foco em:
                    - Clareza e completude dos testes
                    - Cobertura de cenários negativos e positivos
                    - Uso correto de tags, dados e validações
                    Mudanças recentes:
                    #{diff}
                    Contexto:
                    #{context}
        PROMPT
      end
    end
  end
end