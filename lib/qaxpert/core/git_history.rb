module QAxpert
  module Core
    class GitHistory
      def self.extract_diff(repo_path)
        Dir.chdir(repo_path) do
          latest_diff = `git diff HEAD~1 HEAD`
          return latest_diff.empty? ? "Nenhuma alteração detectada" : latest_diff
        end
      rescue => e
        puts "[QAXpert] Erro ao extrair diff Git: #{e.message}"
        return "Erro ao extrair diff"
      end
    end
  end
end