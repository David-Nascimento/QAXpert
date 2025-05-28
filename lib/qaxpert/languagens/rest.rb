module QAxpert
  module Languages
    class Rest
      def analyze(repo_path)
        test_file = Dir.glob(File.join(repo_path, "**", ".rb")) ||
                    Dir.glob(File.join(repo_path, "**", ".java"))

        api_test_files = test_file.select do |path|
          content = File.read(path)
          content.include?("RestAssured") || content.include?("HTTParty")
          content.include?("requests") || content.include?("axios")
        end

        puts "[REST] Encontrados #{api_test_files.count} arquivos de testes encontrados de API"
        api_test_files
      end

      def generate_prompt_for_test(diff, context)
        <<~PROMPT
          Você é um especialista em testes automatizados de APIs REST.
          Avalie o seguinte código e sugira melhorias com foco em:
          - Boas práticas de verificação de respostas HTTP (status, body, headers)
          - Cobertura de casos de erro, segurança e autenticação
          - Clareza e robustez dos testes
          Mudanças recentes:
          #{diff}
          Contexto:
          #{context}
        PROMPT
      end
    end
  end
end