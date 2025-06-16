module QAxpert
  module Languages
    # Enhanced LanguageHandler with parallel file processing and robust file discovery.
    class LanguageHandler
      attr_accessor :diff_override, :verbose

      def initialize(lang:, repo_path:, output_base:, ai_client:, threads: nil)
        self.class.load_config!
        @config_map = self.class.load_config!
        @requested  = normalize_requested_langs(lang, @config_map.keys)

        @repo_path   = repo_path
        @output_base = output_base
        @ai_client   = ai_client
        @threads     = threads || Parallel.processor_count

        @diff_override = nil
        @verbose       = false
        @@processed_groups ||= Set.new
      end

      # Performs analysis for each configured language/framework
      # @return [Hash{Symbol=>Array<String>}] processed files per language
      def analyze_all
        results = {}

        @requested.each do |lang_sym|
          cfg = @config_map[lang_sym]
          raise "Language #{lang_sym} not configured" unless cfg

          # Prepare output directory
          output_dir = File.join(@output_base, cfg['output_sub'])
          FileUtils.mkdir_p(output_dir)

          # Initialize services
          prompt_builder = QAxpert::Services::PromptBuilder.new(cfg['prompt_tpl'])
          result_saver   = QAxpert::Services::ResultSaver.new(output_dir: output_dir,
                                                            file_suffix: cfg['file_suffix'])
          cache_manager  = QAxpert::Services::CacheManager.new(output_dir: output_dir,
                                                              file_suffix: cfg['file_suffix'])

          # Robust file discovery relative to repo_path
          files = discover_files(@repo_path, cfg['patterns'])

          # Parallel processing of files
          entries = Parallel.map(files, in_threads: @threads) do |file|
            content = File.read(file)
            diff    = @diff_override || extract_diff
            prompt  = prompt_builder.build(
              context:      content,
              diff:         diff,
              file_path:    file,
              scenario_name: File.basename(file)
            )

            response, from_cache = cache_manager.fetch_or_store(file) do
              @ai_client.call(prompt)
            end
            result_saver.save(source_file: file, response: response)

            { file: file, suggestion: cache_manager.send(:cache_path_for, file) }
          rescue StandardError => e
            warn "[LanguageHandler][#{lang_sym}] Error processing #{file}: #{e.message}"
            nil
          end.compact

          # Generate report once per syntax group
          group = cfg['syntax_group'] || lang_sym
          unless @@processed_groups.include?(group)
            group_dir = File.join(File.dirname(output_dir), group.to_s)
            FileUtils.mkdir_p(group_dir)
            QAxpert::Core::Reporter.save(output_dir: group_dir,
                                        report_data: entries)
            @@processed_groups << group
          end

          results[lang_sym] = entries.map { |e| e[:file] }
        end

        results
      end

      private

      # Discover files by patterns, relative to base_dir
      def discover_files(base_dir, patterns)
        patterns.flat_map do |pat|
          Dir.glob(File.join(base_dir, pat), File::FNM_CASEFOLD)
        end
        .uniq
        .select { |f| File.file?(f) }
      end

      def extract_diff
        QAxpert::Core::GitHistory.extract_diff(@repo_path)
      rescue StandardError
        ''
      end

      def normalize_requested_langs(lang_param, available)
        if lang_param.nil? || lang_param.to_s.downcase == 'all'
          available
        else
          Array(lang_param).map(&:to_sym)
        end
      end

      # Loads config from YAML only once
      def self.load_config!
        return @config_map if @config_map
        cfg_path = File.expand_path('../../../config/languages.yml', __dir__)
        raise "Config file not found: #{cfg_path}" unless File.exist?(cfg_path)
        raw = YAML.load_file(cfg_path)
        @config_map = raw.transform_keys(&:to_sym)
      end
    end
  end
end
