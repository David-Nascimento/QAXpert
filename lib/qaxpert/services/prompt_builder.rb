module QAxpert
  module Services
    class PromptBuilder
      #
      # @param template [String]  Template do prompt com placeholders %{diff} e %{context}
      #
      def initialize(template:)
        @template = template
      end

      #
      # Substitui %{diff} e %{context} no template e retorna o prompt final.
      #
      # @param diff    [String]
      # @param context [String]
      # @return [String]
      #
      def build(diff:, context:)
        format(@template, diff: diff, context: context)
      end
    end
  end
end
