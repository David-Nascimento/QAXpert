# lib/qaxpert/core/quality_scorer.rb

module QAxpert
  module Core
    # Provides a simple quality scoring for feature or test snippets
    class QualityScorer
      # Scores a block of Gherkin or test code.
      # @param text [String] the feature or test snippet
      # @return [Hash] includes :score (Float) and :metrics (Hash)
      def self.score_feature(text)
        lines = text.to_s.lines.map(&:strip).reject(&:empty?)
        metrics = {}

        # Count scenarios
        scenario_count = lines.count { |l| l =~ /^Scenario/i }
        metrics[:scenario_count] = scenario_count

        # Count steps (Given, When, Then, And)
        step_keywords = %w[Given When Then And But]
        step_count = lines.count { |l| step_keywords.any? { |kw| l.start_with?(kw) } }
        metrics[:step_count] = step_count

        # Assess coverage: at least one scenario and >=3 steps per scenario
        ideal_steps = scenario_count * 3
        coverage_ratio = ideal_steps.zero? ? 0.0 : [step_count.to_f / ideal_steps, 1.0].min
        metrics[:coverage_ratio] = coverage_ratio.round(2)

        # Evaluate specificity: penalize generic placeholders
        generic_terms = %w["nome de usuário" "senha" "título" "descrição" "preço"]
        generic_count = generic_terms.sum { |term| text.include?(term) ? 1 : 0 }
        metrics[:generic_count] = generic_count

        # Compute a base score: coverage (0..1) minus generic penalty
        score = (coverage_ratio * 5) - (generic_count * 0.5)
        # Normalize between 0 and 5
        score = [[score, 0.0].max, 5.0].min

        { score: score.round(2), metrics: metrics }
      end
    end
  end
end
