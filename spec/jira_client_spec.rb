require 'rspec'
require 'json'
require_relative '../lib/qaxpert/jira_client'

module Qaxpert
  module Integrations
    describe JiraClient do
      describe '.fetch_issue' do
        it 'retorna resumo e descrição formatados' do
          allow(Net::HTTP).to receive(:start).and_return(
            double(body: {
              fields: {
                summary: 'Erro ao logar',
                description: {
                  content: [
                    { content: [{ text: 'Usuário informa dados inválidos' }] },
                    { content: [{ text: 'Sistema retorna erro' }] }
                  ]
                }
              }
            }.to_json)
          )

          ENV['JIRA_BASE_URL'] = 'https://fake.atlassian.net'
          ENV['JIRA_EMAIL'] = 'teste@exemplo.com'
          ENV['JIRA_API_TOKEN'] = 'token_fake'

          result = JiraClient.fetch_issue('QA-123')

          expect(result).to include('Resumo: Erro ao logar')
          expect(result).to include('Usuário informa dados inválidos')
          expect(result).to include('Sistema retorna erro')
        end
      end
    end
  end
end
