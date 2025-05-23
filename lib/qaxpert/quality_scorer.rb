module Qaxpert
  class QualityScorer
    def self.score_feature(content)
      score = 0.0

      score += 1.0 if content.include?("Feature:")
      score += 0.5 if content.match?(/^@\w+/)

      scenarios = content.scan(/Scenario:/i)
      score += 1.0 if scenarios.any?

      steps = content.scan(/^\s*(Given|When|Then|And|But)/i)
      score += 1.0 if steps.size.between?(3, 15)

      duplicates = steps.map(&:first).tally.select { |_k, v| v > 1 }
      score += 0.5 if duplicates.empty?

      {
        score: score.round(2),
        feedback: generate_feedback(score)
      }
    end

    def self.generate_feedback(score)
      case score
      when 0..1.5 then "Fraco — cenário precisa ser reestruturado."
      when 1.6..3.0 then "Regular — melhorias recomendadas."
      when 3.1..4.0 then "Bom — cobertura adequada."
      else "Excelente — segue boas práticas de escrita BDD!"
      end
    end
  end
end
