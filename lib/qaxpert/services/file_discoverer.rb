module QAxpert
  module Services
    class FileDiscoverer
      #
      # @param repo_path [String]   Caminho para o repositório
      # @param patterns  [Array<String>]  Array de globs ex: ["**/*.rb", "**/*.feature"]
      #
      def initialize(repo_path:, patterns:)
        @repo_path = repo_path
        @patterns  = Array(patterns)
      end

      #
      # Retorna um array de caminhos completos para todos os arquivos
      # que batem em qualquer dos globs.
      #
      # @return [Array<String>]
      #
      def discover
        @patterns.flat_map do |glob|
          Dir.glob(File.join(@repo_path, glob))
        end.uniq
      end
    end
  end
end
