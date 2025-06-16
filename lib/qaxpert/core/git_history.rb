module QAxpert
  module Core
    class GitHistory
      #
      # Retorna o diff entre dois pontos Git.
      # Se `from_ref` ou `to_ref` não forem informados, usa HEAD~1 e HEAD.
      #
      # @param repo_path [String]
      # @param from_ref  [String, nil]
      # @param to_ref    [String, nil]
      # @return [String]
      #
      def self.extract_diff(repo_path, from_ref: nil, to_ref: nil)
        Dir.chdir(repo_path) do
          base = from_ref || 'HEAD~1'
          alvo = to_ref   || 'HEAD'
         `git -C "#{repo_path}" diff --color=never #{base} #{alvo}`
        end
      rescue StandardError => e
        "[QAxpert] Erro ao extrair diff: #{e.message}"
      end
    end
  end
end
