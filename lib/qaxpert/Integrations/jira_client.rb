

module Qaxpert
  module Integrations
    class JiraClient
      def self.fetch_issue(issue_key)
        base_url = ENV['JIRA_BASE_URL']
        email    = ENV['JIRA_EMAIL']
        token    = ENV['JIRA_API_TOKEN']

        return "❌ Variáveis de ambiente do Jira ausentes." unless base_url && email && token

        url = URI("#{base_url}/rest/api/3/issue/#{issue_key}")
        req = Net::HTTP::Get.new(url)
        req['Authorization'] = "Basic #{Base64.strict_encode64("#{email}:#{token}")}"
        req['Content-Type'] = 'application/json'

        res = Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(req) }
        json = JSON.parse(res.body)

        summary     = json.dig("fields", "summary")
        description = json.dig("fields", "description")["content"].map { |c| c["content"] }.flatten.map { |t| t["text"] rescue nil }.compact.join(" ")

        "Resumo: #{summary}\nDescrição: #{description}"
      rescue => e
        "❌ Erro ao acessar Jira: #{e.message}"
      end
    end
  end
end
