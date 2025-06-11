# Este arquivo garante que o diretório `lib/` esteja presente no $LOAD_PATH,
# permitindo o uso de require relativo para os módulos do projeto.
#
# Carrega diversas bibliotecas padrão do Ruby e gems externas necessárias para o funcionamento da aplicação,
# como manipulação de HTTP, JSON, variáveis de ambiente, parsing de opções de linha de comando, CSV, arquivos, etc.
#
# Em seguida, realiza o require dos principais módulos internos do projeto QAXpert,
# incluindo CLI, parsers, geradores de IA, integrações com clientes LLM (OpenAI, Gemini),
# utilitários, analisadores de qualidade e cobertura, manipuladores de linguagens,
# componentes de core (analisador, histórico do git, cliente LLM, reporter),
# interfaces de clientes e serviços auxiliares (descobridor de arquivos, construtor de prompts,
# salvador de resultados e gerenciador de cache).
#
# Este arquivo centraliza a configuração do ambiente e o carregamento dos componentes essenciais do QAXpert.
# Garante que `lib/` esteja no $LOAD_PATH para que possamos usar `require 'qaxpert/...`
root       = File.expand_path('..', __dir__)
lib_path   = File.join(root, 'lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'net/http'
require 'json'
require 'dotenv'
require 'uri'
require 'base64'
require 'optparse'
require 'csv'
require 'fileutils'
require 'yaml'
require 'erb'
require 'securerandom'
require 'set'

require 'qaxpert/cli'
require 'qaxpert/support/parser'
require 'qaxpert/AI/ai_generator'
require 'qaxpert/Integrations/gemini_client'
require 'qaxpert/Utils/utils'
require 'qaxpert/support/quality_scorer'
require 'qaxpert/support/coverage_analyzer'
require 'qaxpert/Utils/git_analyzer'
require 'qaxpert/Utils/git_utils'
require 'qaxpert/languages/language_handler'
require 'qaxpert/core/analyzer'
require 'qaxpert/core/git_history'
require 'qaxpert/core/llm_client'
require 'qaxpert/core/reporter'

require 'qaxpert/clients/llm_client_interface'
require 'qaxpert/clients/openai_client'
require 'qaxpert/clients/gemini_client'


# Serviços auxiliares
require 'qaxpert/services/file_discoverer'
require 'qaxpert/services/prompt_builder'
require 'qaxpert/services/result_saver'
require 'qaxpert/services/cache_manager' 
