**Qualidade contínua com IA para times ágeis.**

QAXpert é uma ferramenta CLI que gera automaticamente sugestões de cenários de testes BDD com base no código-fonte Ruby. Ideal para analistas de qualidade, desenvolvedores e times DevOps que desejam acelerar a cobertura de testes com apoio de IA.

---

## 🚀 Instalação

```bash
# Clone o repositório
$ git clone https://github.com/seuusuario/qaxpert.git
$ cd qaxpert

# Instale as dependências
$ bundle install

# Configure a chave da API Gemini
$ cp .env.example .env
$ nano .env
# (adicione sua chave na variável GEMINI_API_KEY)

# Instale localmente como uma gem
$ gem build qaxpert.gemspec
$ gem install ./qaxpert-0.1.0.gem
```

---

## 🧪 Uso

```bash
# Execute com um arquivo Ruby
$ qaxpert analyze sample_login.rb
```

A saída será exibida no terminal e também salva em `features/sample_login.feature` com sugestões de testes.

---

## 📂 Estrutura do Projeto

- `lib/qaxpert/parser.rb`: extrai informações do código.
- `lib/qaxpert/ai_generator.rb`: monta o prompt e chama IA.
- `lib/qaxpert/gemini_client.rb`: integração com API Gemini.
- `lib/qaxpert/cli.rb`: executa a lógica de análise.
- `features/`: onde os testes gerados são salvos.
- `spec/`: testes automatizados.

---

## ✅ Testes

```bash
# Execute todos os testes
$ bundle exec rspec
```

---

## 📄 Licença

MIT © David Nascimento