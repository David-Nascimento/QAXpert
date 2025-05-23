module Qaxpert
  class Parser
    def self.read_file(path)
      File.read(path)
    rescue
      warn "❌ Não foi possível ler o arquivo: #{path}"
      ""
    end

    def self.extract_context(code)
      lines = code.lines
      summary = []

      class_name = lines.find { |l| l.strip.start_with?('class ') }
      summary << "Classe detectada: #{class_name.strip}" if class_name

      method_lines = lines.select { |l| l.strip.start_with?('def ') }
      method_lines.each do |line|
        method_signature = line.strip
        method_name = method_signature.split[1]
        summary << "Método: #{method_name}"
      end

      actions = lines.select { |l| l.match(/authenticate|redirect_to|render|params\[:.*\]/) }
      summary << "Ações detectadas:" unless actions.empty?
      actions.each do |line|
        summary << "  - #{line.strip}"
      end

      summary.join("\n")
    end
  end
end