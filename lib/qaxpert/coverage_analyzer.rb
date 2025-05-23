module Qaxpert
  class CoverageAnalyzer
    def self.load_coverage(file_path = 'coverage/.resultset.json')
      return "❌ Arquivo de cobertura não encontrado." unless File.exist?(file_path)

      data = JSON.parse(File.read(file_path))
      result = []

      data.each do |_profile, profile_data|
        profile_data["coverage"].each do |file, lines|
          uncovered = lines.each_with_index.map { |val, idx| idx + 1 if val == 0 }.compact
          next if uncovered.empty?

          result << "Arquivo: #{file}
Linhas não cobertas: #{uncovered.take(10).join(', ')}"
        end
      end

      result.join("

")
    rescue => e
      "❌ Erro ao processar cobertura: #{e.message}"
    end
  end
end
