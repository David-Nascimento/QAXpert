module QAxpert
  module Services
    class ResultSaver
      #
      # @param output_dir  [String]  Pasta onde salvar
      # @param file_suffix [String]  Ex: ".suggestion.txt"
      #
      def initialize(output_dir:, file_suffix:)
        @output_dir  = output_dir
        @file_suffix = file_suffix
        FileUtils.mkdir_p(@output_dir)
      end

      #
      # Salva a resposta de IA (string) em "<base_name><file_suffix>" dentro do output_dir.
      #
      # @param source_file [String] Caminho original do arquivo analisado
      # @param response    [String] Texto retornado pela IA
      #
      # @return [String] Caminho completo onde foi salvo
      #
      def save(source_file:, response:)
        base_name   = File.basename(source_file, '.*')
        output_path = File.join(@output_dir, "#{base_name}#{@file_suffix}")
        File.write(output_path, response)
        output_path
      end
    end
  end
end
