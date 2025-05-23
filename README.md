**Qualidade contínua com IA para times ágeis.**
![QAXpert Banner](https://raw.githubusercontent.com/David-Nascimento/qaxpert/main/diagrama_qaxpert.png)

[![Gem Version](https://img.shields.io/gem/v/qaxpert.svg)](https://rubygems.org/gems/QAXpert)
[![RSpec Tests](https://img.shields.io/badge/tests-passing-brightgreen)](https://github.com/seuusuario/qaxpert/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

QAXpert é uma ferramenta CLI que gera automaticamente sugestões de cenários de testes BDD com base no código-fonte Ruby e contexto de negócio, com suporte a integração Git, cobertura, Jira e análise de qualidade.

---

## 🚀 Instalação

```bash
# Clone o repositório
$ git clone https://github.com/seuusuario/qaxpert.git
$ cd qaxpert

# Instale as dependências
$ bundle install

# Configure as chaves da API Gemini e Jira
$ cp .env.example .env
$ nano .env
```

### .env esperado:
```env
GEMINI_API_KEY=xxxx
JIRA_BASE_URL=https://seu-projeto.atlassian.net
JIRA_EMAIL=seu@email.com
JIRA_API_TOKEN=sua_token
```

```bash
# Instale localmente como uma gem (requer Ruby no PATH)
$ gem build qaxpert.gemspec
$ gem install ./qaxpert-0.1.0.gem
```

> Se estiver no Windows e `qaxpert` não for reconhecido, rode via:
> `ruby bin/qaxpert ...` ou `./bin/qaxpert ...`

---

## 🧪 Comandos disponíveis

### ➤ Analisar código Ruby diretamente:
```bash
qaxpert analyze path/to/arquivo.rb
```

### ➤ Analisar último commit (Git):
```bash
qaxpert analyze-git
```

### ➤ Gerar testes com base na issue da branch atual (Jira):
```bash
qaxpert analyze-jira
```

### ➤ Analisar cobertura de testes (SimpleCov):
```bash
qaxpert analyze-coverage
```

### ➤ Avaliar qualidade de cenários `.feature`:
```bash
qaxpert score features/login.feature
```

---

## 📂 Estrutura do Projeto

- `lib/qaxpert/parser.rb`: extrai informações do código Ruby.
- `lib/qaxpert/ai_generator.rb`: monta o prompt e chama a IA.
- `lib/qaxpert/git_analyzer.rb`: detecta arquivos alterados via Git.
- `lib/qaxpert/integrations/jira_client.rb`: integra com Jira.
- `lib/qaxpert/coverage_analyzer.rb`: avalia linhas não testadas.
- `lib/qaxpert/quality_scorer.rb`: gera pontuação de qualidade dos testes.
- `lib/qaxpert/cli.rb`: comanda a lógica de execução.

---

## ✅ Rodar testes do projeto

```bash
bundle exec rspec
```

---

## 📄 Licença

MIT © David Nascimento