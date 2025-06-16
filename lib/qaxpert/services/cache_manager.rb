module QAxpert
  module Services
    #
    # CacheManager gerencia o armazenamento local de respostas de IA para cada arquivo de teste.
    # Se o arquivo já existe na saída, retorna o conteúdo sem chamar a IA novamente.
    # Caso contrário, executa o bloco (que chama a IA), salva o resultado e retorna o texto.
    #
    class CacheManager
      # Inicializa uma nova instância do CacheManager.
      #
      # @param output_dir [String] Diretório onde os arquivos de cache serão armazenados.
      # @param file_suffix [String] Sufixo a ser adicionado aos arquivos de cache.
      # @param ttl [Integer, nil] Tempo de vida (em segundos) dos arquivos de cache. Opcional.
      #
      # Cria o diretório de saída caso ele não exista e inicializa os contadores de hits e misses.
      def initialize(output_dir:, file_suffix:, ttl: nil)
        @output_dir = output_dir
        @file_suffix = file_suffix
        @ttl = ttl
        @hits = 0
        @misses = 0
        FileUtils.mkdir_p(@output_dir)
      end

      def fetch_or_store(srouce_file)
        cache_file = cache_path_for(srouce_file)
        if File.exist?(cache_file) && !expired?(cache_file)
          @hits += 1
          [File.read(cache_file), true]
        else
          @misses += 1
          content = yield
          write_cache(cache_file, content)
          [content, false]
        end
      end

      def stats
        { hits: @hits, misses: @misses }
      end

      def cache_path_for(source_file)
        base = File.basename(source_file, '.*')
        File.join(@output_dir, "#{base}#{@file_suffix}")
      end

      def write_cache(path, content)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content)
      end

      def expired?(cache_file)
        return false unless @ttl

        Time.now - File.mtime(cache_file) >= @ttl
      end
    end
  end
end
