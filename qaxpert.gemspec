Gem::Specification.new do |spec|
  spec.name          = "qaxpert"
  spec.version       = "0.1.0"
  spec.authors       = ["David Nascimento"]
  spec.email         = ["david@example.com"]

  spec.summary       = "Plataforma de qualidade contínua com IA"
  spec.description   = "Gera sugestões de cenários BDD com base no código-fonte Ruby"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] + ['bin/qaxpert']
  spec.executables   = ['qaxpert']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dotenv'
  spec.add_runtime_dependency 'json'
  spec.add_development_dependency 'rspec'
end