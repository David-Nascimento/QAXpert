require 'rspec'
require_relative '../lib/qaxpert/parser'

describe Qaxpert::Parser do
  describe '.extract_context' do
    it 'extrai a classe, método e ações corretamente de um arquivo Ruby' do
      codigo = <<~RUBY
        class SessionsController
          def create
            email = params[:email]
            senha = params[:senha]
            user = User.authenticate(email, senha)
            if user
              redirect_to :home
            else
              render :login
            end
          end
        end
      RUBY

      contexto = described_class.extract_context(codigo)

      expect(contexto).to include('Classe detectada: class SessionsController')
      expect(contexto).to include('Método: create')
      expect(contexto).to include('params[:email]')
      expect(contexto).to include('User.authenticate')
      expect(contexto).to include('redirect_to')
      expect(contexto).to include('render')
    end
  end
end