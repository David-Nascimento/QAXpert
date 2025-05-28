module QAxpert
  module Languagens
    class Flutter
      def analyzer(repo_path)
        # Detecta arquivos de teste em Dart
        test_files = Dir.glob(repo_path, "test", "**", "*_test.dart")
        puts "[Flutter] Encontrados #{test_files.count} Arquivo de testes"
        test_files
      end

      def generate_prompt_for_test(diff, context)
        <<~PROMPT
                    Gere um Teste Flutter (usando Flutter_test) para o seguinte widget Dart.
          Mudanças recentes:
          #{diff}
          Contexto: 
          #{context}
        PROMPT
      end
    end
  end
end