module Qaxpert
  class Utils
    def self.save_feature_file(source_path, content)
      filename = File.basename(source_path, File.extname(source_path)) + ".feature"
      dest = File.join("features", filename)
      Dir.mkdir("features") unless Dir.exist?("features")
      File.write(dest, content)
      puts "\n💾 Cenário salvo em: #{dest}"
    end
  end
end