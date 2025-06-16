# lib/qaxpert/core/report_txt_generator.rb
module QAxpert
  module Core
    # Generates a clean, readable .txt report following AI suggestion style
    class Reporter
      SECTIONS = [
        'Gherkin Otimizado',
        'Dicas',
        'Assertivas Mais Específicas',
        'Considerações Adicionais',
        'Resumo'
      ].freeze

      # @param output_dir [String] directory where report.txt will be saved
      # @param report_data [Array<Hash>] each hash must have :file and :suggestion paths
      def self.save(output_dir:, report_data:)
        path = File.join(output_dir, 'report.txt')
        File.open(path, 'w') do |f|
          report_data.each do |entry|
            sugg_text = begin
              File.read(entry[:suggestion])
            rescue StandardError
              ''
            end

            # Clean and split by sections
            sections_content = extract_all_sections(sugg_text)

            # Write each section in order
            SECTIONS.each do |header|
              f.puts "#{header}:"
              content = sections_content[header] || []
              content.each do |line|
                f.puts "  #{line.strip}"
              end
              f.puts # blank line
            end
            f.puts '-' * 60
            f.puts # separate entries
          end
        end
        puts "[Reporter] TXT report generated at: #{path}"
      end

      def self.extract_all_sections(text)
        cleaned = text.to_s
                      .gsub(/```[\s\S]*?```/, '')
                      .gsub(/^(?:\+\+\+|---|@@).*$/, '')

        cleaned = cleaned.gsub(/^\s*#.*$/, '') # remove comments
        cleaned = cleaned.gsub(/^\s*$/, '') # remove empty lines
        cleaned = cleaned.gsub(/^\s*[-=]+\s*$/, '') # remove lines with just dashes or equals
        cleaned = cleaned.gsub(/^\s*[*-]\s+/, '') # remove bullet points
        cleaned = cleaned.gsub('*', '') # remove asterisks

        SECTIONS.each_with_object({}) do |header, result|
          result[header] = extract_section(cleaned, header)
        end
      rescue StandardError => e
        puts "[Reporter] Error processing sections: #{e.message}"  
      end

      def self.extract_section(text, header)
        # Regex: header line, then capture until next header or end
        pattern = /
          ^\s*#{Regexp.escape(header)}\s*[:\-]?\s*$\n    # linha exata de cabeçalho (sem asteriscos)
          (.*?)(?=^\s*(?:#{SECTIONS.map(&Regexp.method(:escape)).join('|')})\s*[:\-]?\s*$|\z)
        /imx
        match = text.match(pattern)
        return [] unless match

        match[1].lines.map(&:strip).reject(&:empty?)
      rescue RegexpError => e
        puts "[Reporter] Error processing section '#{header}': #{e.message}"
      end
    end
  end
end
