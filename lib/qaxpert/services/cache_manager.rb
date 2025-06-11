module QAxpert
  module Services
    #
    # CacheManager gerencia o armazenamento local de respostas de IA para cada arquivo de teste.
    # Se o arquivo já existe na saída, retorna o conteúdo sem chamar a IA novamente.
    # Caso contrário, executa o bloco (que chama a IA), salva o resultado e retorna o texto.
    #
    class CacheManager
      #
      # @param output_dir  [String]  Pasta onde ficam os arquivos de sugestão (ex: "./saida/ruby")
      # @param file_suffix [String]  Sufixo adotado para salvar respostas (ex: ".suggestion.txt")
      #
      def initialize(output_dir:, file_suffix:)
        @output_dir  = output_dir
        @file_suffix = file_suffix

        # Garante que a pasta de saída exista
        FileUtils.mkdir_p(@output_dir)
      end

      #
      # Para um arquivo de teste `source_file`, verifica se já existe um cache:
      # - Se existir, lê e retorna [conteúdo, true]
      # - Caso contrário, executa o bloco para gerar a resposta (IA), salva e retorna [conteúdo, false]
      #
      # @param source_file [String]  Caminho original do arquivo de teste (ex: "features/foo.feature")
      # @yield                   Deve retornar a string gerada pela IA (prompt -> resposta)
      # @return [Array]           [ String: resposta (do cache ou nova), Boolean: veio_do_cache ]
      #
      def fetch_or_store(source_file)
        base_name   = File.basename(source_file, '.*')
        cache_file  = File.join(@output_dir, "#{base_name}#{@file_suffix}")

        if File.exist?(cache_file)
          # Já existe cache: retorna o conteúdo armazenado
          cached_content = File.read(cache_file)
          return [cached_content, true]
        end

        # Não há cache: executa o bloco para gerar nova resposta
        new_content = yield
        File.write(cache_file, new_content)
        [new_content, false]
      end
    end
  end
end
