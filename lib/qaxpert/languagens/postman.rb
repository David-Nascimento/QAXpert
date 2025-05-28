module QAxpert
  module Languages
    class Postman
      def analyze(repo_path)
        test_file = Dir.glob(File.join(repo_path, "**", "*.postman_collection.json"))
        puts "[Newman] Encontrados #{test_file.count} coleções postman"
        test_file
      end

      def generate_prompt_for_test(diff, context)
        <<~PROMPT
          Você é um especialista em testes de API com Postman.
                   Avalie a seguinte coleção ou request e sugira melhorias com foco em:
                   - Assertivas claras e relevantes
                   - Cobertura de cenários de erro e edge cases
                   - Reuso de variáveis, ambientes e scripts de pre/post-test
                   Mudanças recentes:
                   #{diff}
                   Contexto:
                   #{context}
        PROMPT
      end
    end
  end
end