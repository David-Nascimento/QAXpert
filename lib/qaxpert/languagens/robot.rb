module QAxpert
  module Languages
    class Robot
      def analyze(repo_path)
        test_file = Dir.glob(File.join(repo_path, "**", "*.robot"))
        puts "[Robot] Encontrados #{test_file.count} arquivos de testes"
        test_file
      end

      def generate_prompt_for_test(diff, context)
        <<~PROMPT
          Você é um especialista em automação com Robot Framework.
                    Analise o seguinte script de teste Robot e sugira melhorias com foco em:
                    - Clareza e estrutura dos testes
                    - Nomenclatura e escopo
                    - Boas práticas de QA automatizado
                    Mudanças recentes:
                    #{diff}
                    Contexto:
                    #{context}
        PROMPT
      end
    end
  end
end