module Qaxpert
  class GitUtils
    def self.current_issue_key
      branch = `git rev-parse --abbrev-ref HEAD`.strip
      match = branch.match(/([A-Z]+-\d+)/)
      match ? match[1] : nil
    end
  end
end
