module Qaxpert
  class AIGenerator
    def self.generate_scenarios(context)
      prompt = "Gere cenários BDD baseados neste código: \n#{context}"
      response = GeminiClient.call(prompt)
      response || "❌ Nenhuma sugestão gerada."
    end
  end
end