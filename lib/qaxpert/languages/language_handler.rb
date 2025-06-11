module QAxpert
  class LanguageHandler
    attr_accessor :diff_override, :verbose

    CONFIG_PATH = File.expand_path('../../../config/languages.yml', __dir__)

    def self.load_config!
      return @config_map if @config_map
      raise "Arquivo de configuração não encontrado: #{CONFIG_PATH}" unless File.exist?(CONFIG_PATH)

      raw = YAML.load_file(CONFIG_PATH)
      @config_map = raw.transform_keys(&:to_sym)
    end

    def initialize(lang:, repo_path:, output_base:, ai_client:)
      self.class.load_config!

      @lang       = lang
      @repo_path  = repo_path
      @output_base = output_base
      @ai_client  = ai_client
      @config     = self.class.instance_variable_get(:@config_map)[lang]
      raise "Linguagem/framework #{lang.inspect} não configurado em #{CONFIG_PATH}" if @config.nil?

      @output_dir = File.join(output_base, @config['output_sub'])
      FileUtils.mkdir_p(@output_dir)

      @discoverer     = QAxpert::Services::FileDiscoverer.new(repo_path: @repo_path, patterns: @config['patterns'])
      @prompt_builder = QAxpert::Services::PromptBuilder.new(template: @config['prompt_tpl'])
      @result_saver   = QAxpert::Services::ResultSaver.new(output_dir: @output_dir, file_suffix: @config['file_suffix'])
      @cache_manager  = QAxpert::Services::CacheManager.new(output_dir: @output_dir,
                                                            file_suffix: @config['file_suffix'])

      @diff_override = nil
      @verbose       = false
    end

    def analyze_all
      test_files = @discoverer.discover
      analysis_results = []

      test_files.each do |file|
        puts "Analisando: #{file}"

        content = File.read(file)
        diff    = @diff_override || extract_diff
        prompt  = @prompt_builder.build(diff: diff, context: content)

        puts "\n[Verbose] Prompt para #{file}:\n#{prompt}\n\n" if @verbose

        response, from_cache = @cache_manager.fetch_or_store(file) do
          @ai_client.call(prompt)
        end
        analysis_results << { file: file, response: response }

        saved_path = File.join(@output_dir, "#{File.basename(file, '.*')}#{@config['file_suffix']}")
        puts from_cache ? "Carregado do cache: #{saved_path}" : "Nova chamada à IA; resposta salva em: #{saved_path}"
      end

      # --- Novo código: gera apenas um relatório por grupo syntax_group ---
      @@processed_groups ||= Set.new
      @syntax_group ||= @config['syntax_group'] || @lang

      unless @@processed_groups.include?(@syntax_group)
        group_dir = File.join(File.dirname(@output_dir), @syntax_group)
        FileUtils.mkdir_p(group_dir)

        QAxpert::Core::Reporter.save(
          output_dir: group_dir,
          analysis_data: analysis_results
        )

        @@processed_groups << @syntax_group
      else
        puts "[LanguageHandler] Relatório para grupo '#{@syntax_group}' já gerado, pulando."
      end
      # ----------------------------------------------------------------------

      test_files
    end

    private

    def extract_diff
      QAxpert::Core::GitHistory.extract_diff(@repo_path)
    rescue StandardError
      ''
    end
  end
end
