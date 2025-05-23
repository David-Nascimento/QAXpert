module Qaxpert
  class GitAnalyzer
    def self.changed_files
      result = `git diff --name-only HEAD~1 HEAD`
      files = result.lines.map(&:strip).select { |f| f.end_with?('.rb') && File.exist?(f) }
      files
    end

    def self.extract_changed_code(file)
      `git diff HEAD~1 HEAD -- #{file}`
    end
  end
end