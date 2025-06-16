**Qualidade contínua com IA para times ágeis.**

![QAXpert Banner](https://github.com/David-Nascimento/QAXpert/blob/QA-123-login-com-erro/img/diagrama_qaxpert.png)

[![Gem Version](https://img.shields.io/gem/v/qaxpert.svg)](https://rubygems.org/gems/QAXpert)
[![RSpec Tests](https://img.shields.io/badge/tests-passing-brightgreen)](https://github.com/seuusuario/qaxpert/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# QAxpert

Gerador de relatórios de qualidade de testes automatizados, com IA, cache e execução paralela.

---

## Instalação

Via RubyGems:

```bash
gem install qaxpert
```

Via Bundler/Gemfile:

```ruby
gem 'qaxpert', path: '.'
```

---

## Uso CLI

```bash
bin/analyze_by_type --type cucumbeR --path ./test_projects/sample_ruby_test --ai gemini
```

* `--type`, `-t`: nome da stack (ex.: `cucumber`, `junit`, `robot`)
* `--path`, `-p`: caminho até a pasta com testes ou repositório
* `--ai`, `-a`: provedor de IA (`openai` ou `gemini`)
* `--threads`, `-T` (opcional): número de threads para paralelismo (padrão: CPUs disponíveis)

Exemplo com threads:

```bash
bin/analyze_by_type -t cucumber -p ./tests -a openai -T 4
```

---

## Cache

Permite armazenar respostas de IA e expirar após um tempo configurável.

No `config/languages.yml`, adicione opcionalmente:

```yaml
cucumber:
  syntax_group: gherkin
  patterns: ['**/*.feature']
  output_sub: 'gherkin'
  file_suffix: '.suggestion.txt'
  cache_ttl: 3600  # TTL em segundos (1 hora)
  prompt_tpl: |
    ...
```

No código, o `CacheManager` será inicializado com:

```ruby
CacheManager.new(
  output_dir: output_dir,
  file_suffix: cfg['file_suffix'],
  ttl: cfg['cache_ttl']
)
```

---

## Paralelismo

O `LanguageHandlerParallel` usa múltiplas threads para acelerar a análise:

```bash
bin/analyze_by_type --type junit --path ./src --ai openai --threads 8
```

---

## Relatórios

Após a execução, em `qaxpert_output/` você encontrará, por grupo de linguagem:

* **report.csv**: planilha com cenários originais, sugestões, scores e seções
* **report.html**: relatório web responsivo, comparativo de cenários
* **report.txt**: versão texto simples, fácil visualização

---

## Publicação da Gem

1. Atualize a versão em `qaxpert.gemspec`:

   ```ruby
   spec.version = 'x.y.z'
   ```
2. Gere o CHANGELOG:

   ```bash
    git log --pretty=format:'\* %h %s' --no-merges > CHANGELOG.md
   ```

3. Build & push:

   ```bash
    gem build qaxpert.gemspec
    gem push qaxpert-x.y.z.gem
    ```

---

## Integração CI

Adicione um workflow em `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  build_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '2.7'
      - run: gem install bundler
      - run: bundle install --jobs 4 --retry 3
      - run: bundle exec rspec
      - run: bundle exec rubocop
```

---

## 📄 Licença

MIT © David Nascimento