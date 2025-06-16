# lib/qaxpert/services/prompt_builder.rb

require 'date'

module QAxpert
  module Services
    # Builds AI prompts from configurable templates using a simple placeholder mechanism.
    class PromptBuilder
      # Variables that must be passed to the template
      REQUIRED_VARS = %i[context diff].freeze
      # Variables that can optionally be passed
      OPTIONAL_VARS = %i[date file_path scenario_name].freeze
      ALL_VARS = REQUIRED_VARS + OPTIONAL_VARS

      # Initializes with a raw template string (must include %{context} and %{diff})
      # @param raw_template [String] the prompt_tpl from languages.yml
      def initialize(raw_template)
        @template = raw_template.to_s.dup
        # If template is empty, fallback to minimal template
        if @template.strip.empty?
          warn '[PromptBuilder] raw_template vazio, usando template padrão'
          @template = "Context: %{context}\nDiff: %{diff}"
        end
        validate_placeholders!
      end

      # Renders the prompt substituting %{var} with provided values
      # @param vars [Hash] must include :context and :diff; can include :date, :file_path, :scenario_name
      # @return [String]
      def build(vars = {})
        # symbolize keys and merge defaults
        values = default_vars.merge(vars.transform_keys(&:to_sym))
        missing = REQUIRED_VARS - values.keys
        raise ArgumentError, "PromptBuilder missing variables: #{missing.join(', ')}" if missing.any?

        # Perform simple substitution
        result = @template.gsub(/%\{(\w+)\}/) do
          key = Regexp.last_match(1).to_sym
          if values.key?(key)
            values[key].to_s
          else
            warn "[PromptBuilder] sem valor para placeholder \#{key}";
            ''
          end
        end
        result
      end

      private

      # Ensure the template contains required placeholders
      def validate_placeholders!
        REQUIRED_VARS.each do |key|
          placeholder = "%{#{key}}"
          unless @template.include?(placeholder)
            raise ArgumentError, "Template inválido: falta placeholder '#{placeholder}'"
          end
        end
      end

      # Default values for optional variables
      def default_vars
        {
          date: Date.today.to_s,
          file_path: '',
          scenario_name: ''
        }
      end
    end
  end
end
