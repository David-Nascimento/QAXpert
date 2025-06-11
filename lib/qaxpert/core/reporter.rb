module QAxpert
  module Core
    class Reporter
      # Remove fences e markdown
      def self.clean_text(text)
        text.to_s.gsub(/```(?:gherkin)?/, '').gsub(/```/, '').gsub(/`/, '').strip
      end

      # Extrai blocos completos de Gherkin, preservando novas linhas
      def self.extract_scenarios(text)
        return [] unless text.is_a?(String) && !text.strip.empty?
        blocks = text.scan(/```(?:gherkin)?\s*\n([\s\S]*?)```/im).flatten
        source = blocks.any? ? blocks.join("\n") : text
        source.scan(/^\s*Scenario(?: Outline)?:.*?(?=^\s*Scenario(?: Outline)?:|\z)/im)
              .map { |blk| clean_text(blk) }
      end

      # Extrai seções de texto após cabeçalho markdown
      def self.extract_section(text, header)
        return [] unless text.include?(header)
        regex = /\*\*#{Regexp.escape(header)}(?: [^*]*)?\*\*\s*([\s\S]*?)(?=\n\d+\.|\z)/im
        match = text.match(regex)
        return [] unless match
        match[1].lines.map(&:strip).reject(&:empty?).map { |l| clean_text(l) }
      end

      def self.save(output_dir:, analysis_data:)
        # CSV
        csv_path = File.join(output_dir, 'report.csv')
        headers = %w[Cenario Original Novo Score_Origem Score_Novo Dicas Assertivas Consideracoes]
        CSV.open(csv_path, 'w', write_headers: true, headers: headers) do |csv|
          analysis_data.each do |entry|
            file = entry[:file]
            ia_text = entry[:response].to_s
            file_text = File.read(file) rescue ''

            orig_list = extract_scenarios(file_text)
            new_list  = extract_scenarios(ia_text)
            dicas = extract_section(ia_text, 'Dicas')
            assertivas = extract_section(ia_text, 'Assertivas Mais Específicas')
            consideracoes = extract_section(ia_text, 'Considerações Adicionais')

            orig_list.each_with_index do |scenario, idx|
              # Title apenas nome do cenário
              title = scenario.sub(/^Scenario(?: Outline)?:\s*/i, '').strip
              newc = new_list[idx] || ''
              os = QualityScorer.score_feature(scenario)[:score]
              ns = newc.empty? ? 0.0 : QualityScorer.score_feature(newc)[:score]

              csv << [
                title,
                scenario,  # bloco completo
                newc,      # novo cenário
                os,
                ns,
                dicas.join(' '),
                assertivas.join(' '),
                consideracoes.join(' ')
              ]
            end
          end
        end
        puts "[Reporter] CSV salvo em: #{csv_path}"

        # HTML seções expansíveis
        html_path = File.join(output_dir, 'report.html')
        grouped = analysis_data.group_by { |e| File.basename(e[:file]) }
        sections = grouped.map do |feature, entries|
          cards = entries.flat_map do |entry|
            file_text = File.read(entry[:file]) rescue ''
            ia_text = entry[:response].to_s
            orig_list = extract_scenarios(file_text)
            new_list  = extract_scenarios(ia_text)
            dicas = extract_section(ia_text, 'Dicas')
            assertivas = extract_section(ia_text, 'Assertivas Mais Específicas')
            consideracoes = extract_section(ia_text, 'Considerações Adicionais')

            orig_list.each_with_index.map do |scenario, idx|
              title = scenario.sub(/^Scenario(?: Outline)?:\s*/i, '').strip
              newc = new_list[idx] || ''
              os = QualityScorer.score_feature(scenario)[:score]
              ns = newc.empty? ? 0.0 : QualityScorer.score_feature(newc)[:score]

              <<~CARD
                <div class="scenario-card">
                  <h3>Scenario: #{ERB::Util.html_escape(title)}</h3>
                  <pre class="wrap">#{ERB::Util.html_escape(scenario)}</pre>
                  <pre class="wrap new">#{ERB::Util.html_escape(newc)}</pre>
                  <p><span class="score-orig">Score Origem: #{os}</span> | <span class="score-new">Score Novo: #{ns}</span></p>
                  <p>Dicas: #{ERB::Util.html_escape(dicas.join(' '))}</p>
                  <p>Assertivas: #{ERB::Util.html_escape(assertivas.join(' '))}</p>
                  <p>Considerações: #{ERB::Util.html_escape(consideracoes.join(' '))}</p>
                </div>
              CARD
            end
          end.join

          <<~SECTION
            <details class="feature-section" open>
              <summary>Feature: #{ERB::Util.html_escape(feature)}</summary>
              #{cards}
            </details>
          SECTION
        end.join

        html = <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Relatório QAxpert</title>
            <style>
              body { font-family: Arial; margin:20px; background:#f4f4f9; }
              h1 { color:#333; }
              details { margin-bottom:15px; }
              summary { background:#1976D2; color:white; padding:8px; font-size:1.1em; cursor:pointer; border-radius:4px; }
              .scenario-card { background:white; margin:10px 0; padding:10px; border-left:4px solid #4CAF50; border-radius:4px; }
              .scenario-card h3 { margin:0; color:#1976D2; }
              .wrap { padding:8px; background:#e8f0fe; border-radius:4px; white-space: pre-wrap; }
              .wrap.new { background:#fff3e0; }
              .score-orig { color:#388E3C; }
              .score-new { color:#D32F2F; }
            </style>
          </head>
          <body>
            <h1>Relatório QAxpert</h1>
            #{sections}
          </body>
          </html>
        HTML
        File.write(html_path, html)
        puts "[Reporter] HTML salvo em: #{html_path}"
      end
    end
  end
end
