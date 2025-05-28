module QAxpert
  module Languages
    class Java
      def analyze(repo_path)
        # detec arquivos .java e estruturas de testes(JUnit/TestNG)
        test_files = Dir.glob(File.join(repo_path, "**", "*Test.java"))
        puts "[Java] Encontrados #{test_files.count} arquivos de testes"
        test_files
      end

      def generate_prompt_for_test(diff, context)
        <<~PROMPT
                    Gere um Teste JUnit4 para o seguinte método Java.
                    Mudanças recentes: 
          #{diff}
                    Contesto: 
          #{context}
        PROMPT
      end
    end
  end
end